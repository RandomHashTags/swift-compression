//
//  RunLengthEncodingTests.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

#if compiler(>=6.0)

#if canImport(Foundation)
import Foundation
#endif

import Testing
@testable import SwiftCompression

// MARK: Compress
struct RunLengthEncodingTests {
    @Test func compressRLE() {
        var data:[UInt8] = [UInt8]("AAAAABBBBBCCCCC".data(using: .utf8)!)
        var compressed:[UInt8] = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        var expected_result:[UInt8] = [196, 65, 196, 66, 196, 67]
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 5, alwaysIncludeRunCount: true)
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 6, alwaysIncludeRunCount: true)
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 6, alwaysIncludeRunCount: false)
        expected_result = data
        #expect(compressed == expected_result)

        data = [UInt8](String(repeating: "A", count: 66).data(using: .utf8)!)
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        expected_result = [255, 65, 193, 65]
        #expect(compressed == expected_result)

        data = [190, 191, 192]
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: false)
        expected_result = [190, 191, 192, 192]
        #expect(compressed == expected_result)

        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        expected_result = [192, 190, 192, 191, 192, 192]
        #expect(compressed == expected_result)
    }
}

// MARK: AsyncStream
extension RunLengthEncodingTests {
    @Test func compressRLEAsyncStream() async {
        var data:[UInt8] = [UInt8]("AAAAABBBBBCCCCC".data(using: .utf8)!)
        var compressed:AsyncStream<UInt8> = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        var index:Int = 0
        var expected_result:[UInt8] = [196, 65, 196, 66, 196, 67]
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 5, alwaysIncludeRunCount: true)
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 6, alwaysIncludeRunCount: true)
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 6, alwaysIncludeRunCount: false)
        expected_result = data
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        data = [UInt8](String(repeating: "A", count: 66).data(using: .utf8)!)
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        expected_result = [255, 65, 193, 65]
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        data = [190, 191, 192]
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: false)
        expected_result = [190, 191, 192, 192]
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        compressed = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        expected_result = [192, 190, 192, 191, 192, 192]
        for await byte in compressed {
            #expect(byte == expected_result[index])
            index += 1
        }
    }
}

// MARK: Decompress
extension RunLengthEncodingTests {
    #if canImport(Foundation)
    @Test func decompressRLE() {
        let string:String = "AAAAABBBBBCCCCC"
        let data:[UInt8] = [UInt8](string.data(using: .utf8)!)
        var compressed:[UInt8] = CompressionTechnique.RunLengthEncoding.compress(data: data, minRun: 3, alwaysIncludeRunCount: true)
        var decompressed:[UInt8] = CompressionTechnique.RunLengthEncoding.decompress(data: compressed)
        #expect(decompressed == data)
        #expect(string == String(data: Data(decompressed), encoding: .utf8))
    }
    #endif
}

#endif