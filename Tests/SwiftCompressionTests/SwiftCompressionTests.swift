//
//  SwiftCompressionTests.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation
import Testing
@testable import SwiftCompression

struct SwiftCompressionTests {
    @Test func compressRunLengthEncoding() {
        var data:Data = "AAAAABBBBBCCCCC".data(using: .utf8)!
        var compressed:Data = RunLengthEncoding.compress(minRun: 3, data: data).data
        var expected_result:Data = Data([196, 65, 196, 66, 196, 67])
        #expect(compressed == expected_result)

        compressed = RunLengthEncoding.compress(minRun: 5, data: data).data
        #expect(compressed == expected_result)

        compressed = RunLengthEncoding.compress(minRun: 6, data: data).data
        #expect(compressed == expected_result)

        compressed = RunLengthEncoding.compress(minRun: 6, includeCountForMinRun: false, data: data).data
        expected_result = data
        #expect(compressed == expected_result)

        data = String(repeating: "A", count: 66).data(using: .utf8)!
        compressed = RunLengthEncoding.compress(minRun: 3, data: data).data
        expected_result = Data([255, 65, 193, 65])
        #expect(compressed == expected_result)

        data = Data([190, 191, 192])
        compressed = RunLengthEncoding.compress(minRun: 3, includeCountForMinRun: false, data: data).data
        expected_result = Data([190, 191, 192, 192])
        #expect(compressed == expected_result)

        compressed = RunLengthEncoding.compress(minRun: 3, data: data).data
        expected_result = Data([192, 190, 192, 191, 192, 192])
        #expect(compressed == expected_result)
    }

    @Test func decompressRunLengthEncoding() {
        let string:String = "AAAAABBBBBCCCCC"
        let data:Data = string.data(using: .utf8)!
        var compressed:Data = RunLengthEncoding.compress(minRun: 3, data: data).data
        var decompressed:Data = RunLengthEncoding.decompress(data: compressed)
        #expect(decompressed == data)
        #expect(string == String(data: decompressed, encoding: .utf8))
    }
}

extension SwiftCompressionTests {
    @Test func compressHuffman() {
        //let data:Data = "aaaaaaaaaabbbbbCCCCC0000000000defghijklm".data(using: .utf8)!
        //var compressed:Data = Huffman.compress(data: data).data

        var builder:Huffman.DataBuilder = Huffman.DataBuilder()
        builder.data.reserveCapacity(100)
        builder.write(bits: [true, false, true, false])
        builder.write(bits: [true, true, true, true, true])
        builder.finalize()
        print("\([UInt8](builder.data))")
    }
}

extension SwiftCompressionTests {
    @Test func decompressSnappy() {
    }
}