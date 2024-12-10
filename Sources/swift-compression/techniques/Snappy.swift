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
        let uncompressed:Int = Int(data[0])
        var index:Int = 1
        while index < data.count {
            let flag:UInt8 = data[index]
            let flagBits:Bits8 = flag.littleEndian.bitsTuple
            switch (flagBits.0, flagBits.1) {
                case (false, false): // literal
                    decompressLiteral(data: data, index: &index, length: Int(flag)-1, into: &decompressed)
                    break
                case (false, true): // copy 1
                    index += 2
                    break
                case (true, false): // copy 2
                    index += 2
                    break
                case (true, true): // copy 4
                    index += 2
                    break
            }
        }
        return decompressed
    }

    private static func decompressLiteral(data: Data, index: inout Int, length: Int, into: inout Data) {
        var length:Int = length
        if length >= 60 {
            index += 1
        }
    }
}