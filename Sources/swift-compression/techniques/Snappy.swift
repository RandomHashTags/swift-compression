//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public extension CompressionTechnique {
    /// The Snappy compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)
    /// 
    /// https://github.com/google/snappy
    enum Snappy {
    }
}

// MARK: Compress
public extension CompressionTechnique.Snappy { // TODO: finish
    @inlinable
    static func compress<S: Sequence<UInt8>>(data: S) -> [UInt8] {
        return []
    }
}

// MARK: Decompress
public extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompressed.reserveCapacity(data.count)
        let totalSize:Int = Int(data[0])
        var index:Int = 1
        let closure:(_ byte: UInt8) -> Void = { decompressed.append($0) }
        while index < totalSize {
            let flagBits:Bits8 = data[index].bitsTuple
            switch (flagBits.6, flagBits.7) {
                case (false, false): decompressLiteral(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                case (false, true):  decompressCopy1(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                case (true, false):  decompressCopy2(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                case (true, true):   decompressCopy4(flagBits: flagBits, index: &index, compressed: data, closure: closure)
            }
        }
        return decompressed
    }

    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress(data: [UInt8], bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            let totalSize:Int = Int(data[0])
            var index:Int = 1
            let closure:(_ byte: UInt8) -> Void = { continuation.yield($0) }
            while index < totalSize {
                let flagBits:Bits8 = data[index].bitsTuple
                switch (flagBits.6, flagBits.7) {
                    case (false, false): decompressLiteral(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                    case (false, true):  decompressCopy1(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                    case (true, false):  decompressCopy2(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                    case (true, true):   decompressCopy4(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                }
            }
            continuation.finish()
        }
    }
}

// MARK: Literal
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the length of the literal.
    @inlinable
    static func decompressLiteral(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        closure: (_ byte: UInt8) -> Void
    ) {
        let length:Int = parseLiteralLength(flagBits: flagBits, index: &index, compressed: compressed)
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            for _ in 0...length {
                closure(p[index])
                index += 1
            }
        }
    }

    /// - Complexity: O(1)?.
    @inlinable
    static func parseLiteralLength(flagBits: Bits8, index: inout Int, compressed: [UInt8]) -> Int {
        let length:UInt8 = UInt8(fromBits: (false, false, flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        index += 1
        var totalLength:Int
        if length >= 60 {
            var bytes:UInt8 = length-59
            totalLength = 0
            compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
                while bytes != 0 {
                    totalLength += Int(p[index])
                    bytes -= 1
                    index += 1
                }
            }
        } else {
            totalLength = Int(length)
        }
        return totalLength
    }
}

// MARK: Copy
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is `4` plus the `UInt8` created from the `flagBits`.
    @inlinable
    static func decompressCopy1(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        closure: (_ byte: UInt8) -> Void
    ) {
        var bytes:UInt8 = 4 + UInt8(fromBits: (flagBits.3, flagBits.4, flagBits.5))
        let bits:Bits8 = compressed[index+1].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (flagBits.0, flagBits.1, flagBits.2, bits.0, bits.1, bits.2, bits.3, bits.4, bits.5, bits.6, bits.7))
        var begins:Int = index - Int(offset)
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            while bytes != 0 {
                closure(p[begins])
                begins += 1
                bytes -= 1
            }
        }
        index += 2
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    static func decompressCopy2(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        closure: (_ byte: UInt8) -> Void
    ) {
        let bits0:Bits8 = compressed[index+1].bitsTuple, bits1:Bits8 = compressed[index+2].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 3, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    static func decompressCopy4(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        closure: (_ byte: UInt8) -> Void
    ) {
        let bits0:Bits8 = compressed[index+1].bitsTuple
        let bits1:Bits8 = compressed[index+2].bitsTuple
        let bits2:Bits8 = compressed[index+3].bitsTuple
        let offset:UInt32 = UInt32(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7,
            bits2.0, bits2.1, bits2.2, bits2.3, bits2.4, bits2.5, bits2.6, bits2.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 5, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    static func decompressCopyN<T: FixedWidthInteger>(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        offset: T,
        readBytes: Int,
        closure: (_ byte: UInt8) -> Void
    ) {
        var bytes:UInt8 = UInt8(fromBits: (flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        var begins:Int = index - Int(offset)
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            while bytes != 0 {
                closure(p[begins])
                begins += 1
                bytes -= 1
            }
        }
        index += readBytes
    }
}

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compresses this data using the Snappy technique.
    /// - Returns: `self`.
    @discardableResult
    @inlinable
    mutating func decompressSnappy() -> Self {
        self = CompressionTechnique.Snappy.decompress(data: self)
        return self
    }

    /// Compress a copy of this data using the Snappy technique.
    /// - Returns: The compressed data.
    @inlinable
    func decompressedSnappy() -> [UInt8] {
        return CompressionTechnique.Snappy.decompress(data: self)
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Compress this data to a stream using the Snappy technique.
    /// - Parameters:
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that decompresses the data.
    @inlinable
    func decompressSnappy(
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.Snappy.decompress(data: self, bufferingPolicy: limit)
    }
}