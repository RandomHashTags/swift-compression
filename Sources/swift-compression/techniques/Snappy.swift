//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// https://en.wikipedia.org/wiki/Snappy_(compression)
public extension CompressionTechnique {
    enum Snappy {
    }
}

// MARK: Compress data
public extension CompressionTechnique.Snappy { // TODO: finish
    @inlinable
    static func compress(data: [UInt8]) -> CompressionResult {
        var compressed:[UInt8] = []
        compressed.reserveCapacity(data.count)
        return CompressionResult(data: compressed)
    }
}

// MARK: Decompress data
public extension CompressionTechnique.Snappy {
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompressed.reserveCapacity(data.count)
        let totalSize:Int = Int(data[0])
        var index:Int = 1
        while index < totalSize {
            let flag:UInt8 = data[index]
            let flagBits:Bits8 = flag.bitsTuple
            //print("decompress;index=\(index);flag=\(flag);flagBits=\(flagBits)")
            switch (flagBits.6, flagBits.7) {
                case (false, false): decompressLiteral(flagBits: flagBits, index: &index, compressed: data, into: &decompressed)
                case (false, true):  decompressCopy1(flagBits: flagBits, index: &index, compressed: data, into: &decompressed)
                case (true, false):  decompressCopy2(flagBits: flagBits, index: &index, compressed: data, into: &decompressed)
                case (true, true):   decompressCopy4(flagBits: flagBits, index: &index, compressed: data, into: &decompressed)
            }
        }
        return decompressed
    }
}

// MARK: Literal
extension CompressionTechnique.Snappy {
    @inlinable
    static func decompressLiteral(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        into data: inout [UInt8]
    ) {
        let length:Int = parseLiteralLength(flagBits: flagBits, index: &index, compressed: compressed)
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            for _ in 0...length {
                data.append(p[index])
                index += 1
            }
        }
    }

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
    @inlinable
    static func decompressCopy1(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        into data: inout [UInt8]
    ) {
        var bytes:UInt8 = 4 + UInt8(fromBits: (flagBits.3, flagBits.4, flagBits.5))
        let bits:Bits8 = compressed[index+1].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (flagBits.0, flagBits.1, flagBits.2, bits.0, bits.1, bits.2, bits.3, bits.4, bits.5, bits.6, bits.7))
        var begins:Int = index - Int(offset)
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            while bytes != 0 {
                data.append(p[begins])
                begins += 1
                bytes -= 1
            }
        }
        index += 2
    }
    @inlinable
    static func decompressCopy2(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        into data: inout [UInt8]
    ) {
        let bits0:Bits8 = compressed[index+1].bitsTuple, bits1:Bits8 = compressed[index+2].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, into: &data, offset: offset, readBytes: 3)
    }
    @inlinable
    static func decompressCopy4(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        into data: inout [UInt8]
    ) {
        let bits0:Bits8 = compressed[index+1].bitsTuple
        let bits1:Bits8 = compressed[index+2].bitsTuple
        let bits2:Bits8 = compressed[index+3].bitsTuple
        let offset:UInt32 = UInt32(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7,
            bits2.0, bits2.1, bits2.2, bits2.3, bits2.4, bits2.5, bits2.6, bits2.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, into: &data, offset: offset, readBytes: 5)
    }
    @inlinable
    static func decompressCopyN<T: FixedWidthInteger>(
        flagBits: Bits8,
        index: inout Int,
        compressed: [UInt8],
        into data: inout [UInt8],
        offset: T,
        readBytes: Int
    ) {
        var bytes:UInt8 = UInt8(fromBits: (flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        var begins:Int = index - Int(offset)
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            while bytes != 0 {
                data.append(p[begins])
                begins += 1
                bytes -= 1
            }
        }
        index += readBytes
    }
}