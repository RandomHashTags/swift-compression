//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public extension CompressionTechnique {
    /// The Snappy (Zippy) compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)
    /// 
    /// https://github.com/google/snappy
    static let snappy:Snappy = Snappy()

    struct Snappy : Compressor {
        public var algorithm : CompressionAlgorithm { .snappy }
    }
}

// MARK: Compress
public extension CompressionTechnique.Snappy { // TODO: finish
    /// - Parameters:
    ///   - data: A sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}

// MARK: Decompress
public extension CompressionTechnique.Snappy {
    /// - Parameters:
    ///   - data: A collection of bytes to decompress.
    ///   - closure: The logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) {
        let totalSize:Int = Int(data[data.startIndex])
        var index:Int = 1
        while index < totalSize {
            let flagBits:Bits8 = data[data.index(data.startIndex, offsetBy: index)].bitsTuple
            switch (flagBits.6, flagBits.7) {
                case (false, false): decompressLiteral(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                case (false, true):  decompressCopy1(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                case (true, false):  decompressCopy2(flagBits: flagBits, index: &index, compressed: data, closure: closure)
                case (true, true):   decompressCopy4(flagBits: flagBits, index: &index, compressed: data, closure: closure)
            }
        }
    }
}

// MARK: Literal
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the length of the literal.
    @inlinable
    func decompressLiteral<C: Collection<UInt8>>(
        flagBits: Bits8,
        index: inout Int,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let length:Int = parseLiteralLength(flagBits: flagBits, index: &index, compressed: compressed)
        for _ in 0...length {
            closure(compressed[compressed.index(compressed.startIndex, offsetBy: index)])
            index += 1
        }
    }

    /// - Complexity: O(1)?.
    @inlinable
    func parseLiteralLength<C: Collection<UInt8>>(flagBits: Bits8, index: inout Int, compressed: C) -> Int {
        let length:UInt8 = UInt8(fromBits: (false, false, flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        index += 1
        var totalLength:Int
        if length >= 60 {
            var bytes:UInt8 = length-59
            totalLength = 0
            while bytes != 0 {
                totalLength += Int(compressed[compressed.index(compressed.startIndex, offsetBy: index)])
                bytes -= 1
                index += 1
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
        flagBits: Bits8,
        index: inout Int,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        var bytes:UInt8 = 4 + UInt8(fromBits: (flagBits.3, flagBits.4, flagBits.5))
        let bits:Bits8 = compressed[compressed.index(compressed.startIndex, offsetBy: index+1)].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (flagBits.0, flagBits.1, flagBits.2, bits.0, bits.1, bits.2, bits.3, bits.4, bits.5, bits.6, bits.7))
        var begins:Int = index - Int(offset)
        while bytes != 0 {
            closure(compressed[compressed.index(compressed.startIndex, offsetBy: begins)])
            begins += 1
            bytes -= 1
        }
        index += 2
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopy2<C: Collection<UInt8>>(
        flagBits: Bits8,
        index: inout Int,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let bits0:Bits8 = compressed[compressed.index(compressed.startIndex, offsetBy: index+1)].bitsTuple
        let bits1:Bits8 = compressed[compressed.index(compressed.startIndex, offsetBy: index+2)].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 3, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopy4<C: Collection<UInt8>>(
        flagBits: Bits8,
        index: inout Int,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let bits0:Bits8 = compressed[compressed.index(compressed.startIndex, offsetBy: index+1)].bitsTuple
        let bits1:Bits8 = compressed[compressed.index(compressed.startIndex, offsetBy: index+2)].bitsTuple
        let bits2:Bits8 = compressed[compressed.index(compressed.startIndex, offsetBy: index+3)].bitsTuple
        let offset:UInt32 = UInt32(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7,
            bits2.0, bits2.1, bits2.2, bits2.3, bits2.4, bits2.5, bits2.6, bits2.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 5, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopyN<C: Collection<UInt8>, T: FixedWidthInteger>(
        flagBits: Bits8,
        index: inout Int,
        compressed: C,
        offset: T,
        readBytes: Int,
        closure: (_ byte: UInt8) -> Void
    ) {
        var bytes:UInt8 = UInt8(fromBits: (flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        var begins:Int = index - Int(offset)
        while bytes != 0 {
            closure(compressed[compressed.index(compressed.startIndex, offsetBy: begins)])
            begins += 1
            bytes -= 1
        }
        index += readBytes
    }
}