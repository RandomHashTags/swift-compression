//
//  SwiftCompressionTests.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

#if compiler(>=6.0)

import Foundation
import Testing
@testable import SwiftCompression

struct SwiftCompressionTests {
    @Test func compressRunLengthEncoding() {
        var data:[UInt8] = [UInt8]("AAAAABBBBBCCCCC".data(using: .utf8)!)
        var compressed:[UInt8] = CompressionTechnique.RunLengthEncoding.compress(minRun: 3, data: data).data
        var expected_result:[UInt8] = [196, 65, 196, 66, 196, 67]
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(minRun: 5, data: data).data
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(minRun: 6, data: data).data
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(minRun: 6, includeCountForMinRun: false, data: data).data
        expected_result = data
        #expect(compressed == expected_result)

        data = [UInt8](String(repeating: "A", count: 66).data(using: .utf8)!)
        compressed = CompressionTechnique.RunLengthEncoding.compress(minRun: 3, data: data).data
        expected_result = [255, 65, 193, 65]
        #expect(compressed == expected_result)

        data = [190, 191, 192]
        compressed = CompressionTechnique.RunLengthEncoding.compress(minRun: 3, includeCountForMinRun: false, data: data).data
        expected_result = [190, 191, 192, 192]
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(minRun: 3, data: data).data
        expected_result = [192, 190, 192, 191, 192, 192]
        #expect(compressed == expected_result)
    }

    @Test func decompressRunLengthEncoding() {
        let string:String = "AAAAABBBBBCCCCC"
        let data:[UInt8] = [UInt8](string.data(using: .utf8)!)
        var compressed:[UInt8] = CompressionTechnique.RunLengthEncoding.compress(minRun: 3, data: data).data
        var decompressed:[UInt8] = CompressionTechnique.RunLengthEncoding.decompress(data: compressed)
        #expect(decompressed == data)
        #expect(string == String(data: Data(decompressed), encoding: .utf8))
    }
}

extension SwiftCompressionTests {
    @Test func compressHuffman() {
        //let data:[UInt8] = [UInt8]("aaaaaaaaaabbbbbCCCCC0000000000defghijklm".data(using: .utf8)!)
        //var compressed:[Unt8] = Huffman.compress(data: data).data
    }
}

extension SwiftCompressionTests {
    @Test func decompressSnappy() {
        var string:String = "51 f0 42 57 69 6b 69 70 65 64 69 61 20 69 73 20"
        string += "61 20 66 72 65 65 2c 20 77 65 62 2d 62 61 73 65"
        string += "64 2c 20 63 6f 6c 6c 61 62 6f 72 61 74 69 76 65"
        string += "2c 20 6d 75 6c 74 69 6c 69 6e 67 75 61 6c 20 65"
        string += "6e 63 79 63 6c 6f 09 3f 1c 70 72 6f 6a 65 63 74"
        string += "2e"
        string.removeAll(where: { $0.isWhitespace })
        let hex = string.hexadecimal
        let data:[UInt8] = [UInt8](hex)
        let decompressed:[UInt8] = CompressionTechnique.Snappy.decompress(data: data)
        #expect(String(data: Data(decompressed), encoding: .utf8) == "Wikipedia is a free, web-based, collaborative, multilingual encyclopedia project.")
    }
}

#endif