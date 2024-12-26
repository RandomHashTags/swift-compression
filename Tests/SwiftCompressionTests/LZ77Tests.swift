//
//  LZ77Tests.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompression

struct LZ77Tests {
    static let string:String = "abracadabra abracadabra"
    static let compressed:[UInt8] = CompressionTechnique.LZ77(windowSize: 10, bufferSize: 6).compress(data: [UInt8](string.utf8)).data

    @Test func compressLZ77() {
        #expect(Self.compressed == [0, 0, 0, 97, 0, 0, 0, 98, 0, 0, 0, 114, 0, 3, 1, 99, 0, 5, 1, 100, 0, 7, 4, 32, 0, 5, 4, 99, 0, 10, 1, 100, 0, 7, 4, 0])
    }
    @Test func decompressLZ77() {
        let result:[UInt8] = CompressionTechnique.LZ77(windowSize: 10, bufferSize: 6).decompress(data: Self.compressed)
        #expect(result == [UInt8](Self.string.utf8))
    }
}

#endif