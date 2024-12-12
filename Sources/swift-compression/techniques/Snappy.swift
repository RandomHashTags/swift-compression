//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

// https://en.wikipedia.org/wiki/Snappy_(compression)
public enum Snappy { // TODO: finish
}

// MARK: Compress data
public extension Snappy {
    @inlinable
    static func compress(data: Data) -> CompressionResult {
        var compressed:Data = Data()
        compressed.reserveCapacity(data.count)
        return CompressionResult(data: compressed)
    }
}

// MARK: Decompress data
public extension Snappy {
    @inlinable
    static func decompress(data: Data) -> Data {
        var decompressed:Data = Data()
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
public extension Snappy {
    @inlinable
    static func decompressLiteral(
        flagBits: Bits8,
        index: inout Int,
        compressed: Data,
        into data: inout Data
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
    static func parseLiteralLength(flagBits: Bits8, index: inout Int, compressed: Data) -> Int {
        let length:UInt8 = UInt8(fromBits: (false, false, flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        index += 1
        var totalLength:Int
        if length >= 60 {
            var bytes:UInt8 = length-59
            totalLength = 0
            compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer)in
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
extension Snappy {
    @inlinable
    static func decompressCopy1(
        flagBits: Bits8,
        index: inout Int,
        compressed: Data,
        into data: inout Data
    ) {
        var bytes:UInt8 = 4 + UInt8(fromBits: (flagBits.3, flagBits.4, flagBits.5))
        let nextBits:Bits8 = compressed[index+1].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (flagBits.0, flagBits.1, flagBits.2, nextBits.0, nextBits.1, nextBits.2, nextBits.3, nextBits.4, nextBits.5, nextBits.6, nextBits.7))
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
        compressed: Data,
        into data: inout Data
    ) {
        let nextBits:Bits8 = compressed[index+1].bitsTuple, finalBits:Bits8 = compressed[index+2].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (
            nextBits.0, nextBits.1, nextBits.2, nextBits.3, nextBits.4, nextBits.5, nextBits.6, nextBits.7,
            finalBits.0, finalBits.1, finalBits.2, finalBits.3, finalBits.4, finalBits.5, finalBits.6, finalBits.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, into: &data, offset: offset, readBytes: 3)
    }
    @inlinable
    static func decompressCopy4(
        flagBits: Bits8,
        index: inout Int,
        compressed: Data,
        into data: inout Data
    ) {
        let secondBits:Bits8 = compressed[index+1].bitsTuple
        let thirdBits:Bits8 = compressed[index+2].bitsTuple
        let finalBits:Bits8 = compressed[index+3].bitsTuple
        let offset:UInt32 = UInt32(fromBits: (
            secondBits.0, secondBits.1, secondBits.2, secondBits.3, secondBits.4, secondBits.5, secondBits.6, secondBits.7,
            thirdBits.0, thirdBits.1, thirdBits.2, thirdBits.3, thirdBits.4, thirdBits.5, thirdBits.6, thirdBits.7,
            finalBits.0, finalBits.1, finalBits.2, finalBits.3, finalBits.4, finalBits.5, finalBits.6, finalBits.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, into: &data, offset: offset, readBytes: 5)
    }
    @inlinable
    static func decompressCopyN<T: FixedWidthInteger>(
        flagBits: Bits8,
        index: inout Int,
        compressed: Data,
        into data: inout Data,
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