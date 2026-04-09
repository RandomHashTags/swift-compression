
import ByteBuilder
import SwiftCompressionUtilities

extension Snappy: Decompressor {
    public typealias ConcreteDecompressionConfiguration = CompressConfiguration
    public typealias ConcreteDecompressionResult = [UInt8]

    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - reserveCapacity: Ignored.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration = .default
    ) throws(DecompressionError) -> [UInt8] {
        var decompressed = [UInt8]()
        var index = data.startIndex
        let length:Int = try decompressLength(data: data, index: &index)
        decompressed.reserveCapacity(length)
        try decompress(data: data, index: &index, amount: length) { decompressed.append($0) }
        return decompressed
    }

    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - index: Where to begin decompressing data.
    ///   - amount: Number of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    func decompress<C: Collection<UInt8>>(
        data: C,
        index: inout C.Index,
        amount: Int,
        closure: (UInt8) -> Void
    ) throws(DecompressionError) {
        guard let endIndex = data.index(data.startIndex, offsetBy: amount, limitedBy: data.endIndex) else { throw DecompressionError.malformedInput }
        while index < endIndex {
            let control = data[index]
            switch control & 0b11 {
            case 0: decompressLiteral(flagBits: control, index: &index, compressed: data, closure: closure)
            case 1: decompressCopy1(flagBits: control, index: &index, compressed: data, closure: closure)
            case 2: decompressCopy2(flagBits: control, index: &index, compressed: data, closure: closure)
            case 3: decompressCopy4(flagBits: control, index: &index, compressed: data, closure: closure)
            default: throw DecompressionError.malformedInput
            }
        }
    }

    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - index: Where to begin parsing the uncompressed length.
    /// - Returns: The uncompressed length, as described in the `Preamble` at https://github.com/google/snappy/blob/main/format_description.txt .
    /// - Complexity: O(1).
    func decompressLength<C: Collection<UInt8>, I: FixedWidthInteger>(
        data: C,
        index: inout C.Index
    ) throws(DecompressionError) -> I {
        var totalSize:I
        var byte = data[index]
        if byte & 0b10000000 != 0 {
            totalSize = I(byte)
            data.formIndex(after: &index)
            guard let second = data[positive: index] else { throw DecompressionError.malformedInput }
            byte = second
            var shift = 7
            while byte & 0b10000000 != 0 {
                totalSize |= I(byte) << shift
                shift += 7
                data.formIndex(after: &index)
                if let next = data[positive: index] {
                    byte = next
                } else {
                    throw DecompressionError.malformedInput
                }
            }
            // final length byte
            totalSize |= I(byte) << shift
        } else {
            totalSize = I(byte)
        }
        data.formIndex(after: &index)
        return totalSize
    }
}

// MARK: Literal
extension Snappy {
    /// - Complexity: O(_n_) where _n_ is the length of the literal.
    func decompressLiteral<C: Collection<UInt8>>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let length = decompressLiteralLength(flagBits: flagBits, index: &index, compressed: compressed)
        for _ in 0...length {
            closure(compressed[index])
            compressed.formIndex(after: &index)
        }
    }

    /// - Complexity: O(1).
    func decompressLiteralLength<C: Collection<UInt8>>(flagBits: UInt8, index: inout C.Index, compressed: C) -> Int {
        let length = flagBits >> 2 // ignore tag bits
        compressed.formIndex(after: &index)
        var totalLength:Int
        if length >= 60 {
            totalLength = 0
            for _ in 0..<length-59 {
                totalLength += Int(compressed[index])
                compressed.formIndex(after: &index)
            }
        } else {
            totalLength = Int(length)
        }
        return totalLength
    }
}

// MARK: Copy
extension Snappy {
    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    func decompressCopy1<C: Collection<UInt8>>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let length = 4 + ((flagBits >> 2) & 0b00000111)
        let offset = Int(((UInt16(flagBits) << 8) & 0b11100000) + UInt16(compressed[compressed.index(index, offsetBy: 1)]))
        var begins = compressed.index(index, offsetBy: -offset)
        for _ in 0..<length {
            closure(compressed[begins])
            compressed.formIndex(after: &begins)
        }
        compressed.formIndex(&index, offsetBy: 2)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    func decompressCopy2<C: Collection<UInt8>>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        //let offset:UInt16 = UInt16( UInt16(compressed[compressed.index(index, offsetBy: 1)]) << 8 | UInt16(compressed[compressed.index(index, offsetBy: 2)]) )
        let offset = UInt16(fromBits: 
            compressed[compressed.index(index, offsetBy: 1)],
            compressed[compressed.index(index, offsetBy: 2)]
        )
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 3, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    func decompressCopy4<C: Collection<UInt8>>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let offset = UInt32.init(fromBits: 
            compressed[compressed.index(index, offsetBy: 1)],
            compressed[compressed.index(index, offsetBy: 2)],
            compressed[compressed.index(index, offsetBy: 3)]
        )
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 5, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    func decompressCopyN<C: Collection<UInt8>, T: FixedWidthInteger>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        offset: T,
        readBytes: Int,
        closure: (_ byte: UInt8) -> Void
    ) {
        let length = flagBits & 0b11111100
        //print("decompressCopyN;readBytes=\(readBytes);length=\(length)")
        var begins = compressed.index(index, offsetBy: -Int(offset))
        for _ in 0..<length {
            closure(compressed[begins])
            compressed.formIndex(after: &begins)
        }
        compressed.formIndex(&index, offsetBy: readBytes)
    }
}

// MARK: Stream
extension Snappy {
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - continuation: Yielding async throwing stream continuation.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func decompress(
        data: some Collection<UInt8>,
        continuation: AsyncThrowingStream<UInt8, Error>.Continuation
    ) throws(DecompressionError) {
        var index = data.startIndex
        let length:Int = try decompressLength(data: data, index: &index)
        try decompress(data: data, index: &index, amount: length) { continuation.yield($0) }
    }
}