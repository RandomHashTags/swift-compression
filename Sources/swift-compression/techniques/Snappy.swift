//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

// https://en.wikipedia.org/wiki/Snappy_(compression)
enum Snappy { // TODO: finish
}

// MARK: Compress data
extension Snappy {
    static func compress(data: Data) -> CompressionResult {
        var compressed:Data = Data()
        compressed.reserveCapacity(data.count)
        return CompressionResult(data: compressed)
    }
}

// MARK: Decompress data
extension Snappy {
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
                case (false, false): // literal
                    decompressLiteral(flagBits: flagBits, index: &index, compressed: data, into: &decompressed)
                    return decompressed
                case (false, true): // copy 1
                    return decompressed
                    index += 2
                    break
                case (true, false): // copy 2
                    return decompressed
                    index += 2
                    break
                case (true, true): // copy 4
                    return decompressed
                    index += 2
                    break
            }
        }
        return decompressed
    }
}

// MARK: Literal
private extension Snappy {
    static func decompressLiteral(
        flagBits: Bits8,
        index: inout Int,
        compressed: Data,
        into data: inout Data
    ) {
        let length:Int = parseLiteralLength(flagBits: flagBits, index: &index, compressed: compressed)
        //print("decompressLiteral;index=\(index);length=\(length)")
        compressed.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            for _ in 0..<length {
                data.append(p[index])
                index += 1
            }
        }
    }

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