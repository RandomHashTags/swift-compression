
import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The Snappy (Zippy) compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)
    /// 
    /// https://github.com/google/snappy
    @inlinable
    public static func snappy(windowSize: Int = Int(UInt16.max)) -> Snappy {
        return Snappy(windowSize: windowSize)
    }

    public struct Snappy: Compressor, Decompressor {

        /// Size of the window.
        public let windowSize:Int

        public init(windowSize: Int = Int(UInt16.max)) {
            self.windowSize = windowSize
        }

        @inlinable public var algorithm: CompressionAlgorithm { .snappy(windowSize: windowSize) }
        @inlinable public var quality: CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.Snappy {
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) throws(CompressionError) -> UInt8? {
        return nil
    }
    public func compress(data: some Collection<UInt8>, reserveCapacity: Int) throws -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation
    }
}
/*
extension CompressionTechnique.Snappy { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        var index = data.startIndex
        while index != data.endIndex {
            let (length, matchLength, offset) = longestMatch(data, from: index)
            if matchLength == 0 {
                let next = data.index(index, offsetBy: length)
                compressLiteral(data[index..<next], closure: closure)
                index = next
            } else {
                compressCopy(length: matchLength, offset: offset, closure: closure)
                index = data.index(index, offsetBy: matchLength)
            }
        }
        return nil
    }

    @inlinable
    func longestMatch<C: Collection<UInt8>>(_ data: C, from startIndex: C.Index) -> (length: Int, matchLength: Int, offset: Int) {
        let maxLength = 60
        var longestMatchLength = 0
        var offset = 0

        var length = 0
        var index = startIndex
        while length < maxLength && index != data.endIndex {
            let starts = data.index(index, offsetBy: -min(length, windowSize), limitedBy: data.startIndex) ?? data.startIndex
            let longestMatch = longestCommonPrefix(data, index1: index, index2: starts)
            if length > longestMatchLength {
                longestMatchLength = longestMatch
                offset = data.distance(from: starts, to: index)
            }
            length += 1
            index = data.index(after: index)
        }
        return (length, longestMatchLength, offset: offset)
    }

    @inlinable
    func longestCommonPrefix<C: Collection<UInt8>>(_ data: C, index1: C.Index, index2: C.Index) -> Int {
        var length = 0
        var index1 = index1
        var index2 = index2
        while index1 != data.endIndex && index2 != data.endIndex && data[index1] == data[index2] {
            length += 1
            index1 = data.index(after: index1)
            index2 = data.index(after: index2)
        }
        return length
    }
}

// MARK: Literal
extension CompressionTechnique.Snappy {
    @inlinable
    func compressLiteral<C: Collection<UInt8>>(_ data: C, closure: (UInt8) -> Void) {
        let count = data.count
        if count < 60 {
            closure(UInt8(count << 2))
        } else {
            closure(UInt8(60 << 2))
            closure(UInt8(count))
        }
        for value in data {
            closure(value)
        }
    }
}

// MARK: Copy
extension CompressionTechnique.Snappy {
    @inlinable
    func compressCopy(length: Int, offset: Int, closure: (UInt8) -> Void) {
        if length < 12 && offset < 2048 {
            let cmd = UInt8((offset >> 8) << 5 | (length - 4) << 2 | 1)
            closure(cmd)
            closure(UInt8(offset & 0xFF))
        } else {
            closure(UInt8((length - 1) << 2) | 2)
            closure(UInt8(offset & 0xFF))
            closure(UInt8((offset >> 8) & 0xFF))
        }
    }
}*/

// MARK: Decompress
extension CompressionTechnique.Snappy {
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - reserveCapacity: Ignored.
    @inlinable
    public func decompress(
        data: some Collection<UInt8>,
        reserveCapacity: Int = 0
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
    ///   - continuation: Yielding async throwing stream continuation.
    @inlinable
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func decompress(
        data: some Collection<UInt8>,
        continuation: AsyncThrowingStream<UInt8, Error>.Continuation
    ) throws(DecompressionError) {
        var index = data.startIndex
        let length:Int = try decompressLength(data: data, index: &index)
        try decompress(data: data, index: &index, amount: length) { continuation.yield($0) }
    }

    /// Calling this function directly will throw a DecompressionError.unsupportedOperation.
    @available(*, deprecated, message: "Use decompress(data:index:amount:closure:) instead")
    public func decompress(data: some Collection<UInt8>, closure: (UInt8) -> Void) throws(DecompressionError) {
        throw DecompressionError.unsupportedOperation("Use decompress(data:index:amount:closure:) instead")
    }

    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - index: Where to begin decompressing data.
    ///   - amount: Number of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<C: Collection<UInt8>>(
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
    @inlinable
    func decompressLength<C: Collection<UInt8>, I: FixedWidthInteger>(
        data: C,
        index: inout C.Index
    ) throws(DecompressionError) -> I {
        var totalSize:I
        var byte = data[index]
        if byte & 0b10000000 != 0 {
            totalSize = I(byte)
            data.formIndex(after: &index)
            guard let second = data.getPositive(index) else { throw DecompressionError.malformedInput }
            byte = second
            var shift = 7
            while byte & 0b10000000 != 0 {
                totalSize |= I(byte) << shift
                shift += 7
                data.formIndex(after: &index)
                if let next = data.getPositive(index) {
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
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the length of the literal.
    @inlinable
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
    @inlinable
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
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
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
    @inlinable
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
    @inlinable
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
    @inlinable
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