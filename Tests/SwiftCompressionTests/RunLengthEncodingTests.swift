//
//  RunLengthEncodingTests.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompressionUtilities

// MARK: Compress
struct RunLengthEncodingTests {
    @Test func compressRLE() throws {
        var data:[UInt8] = [UInt8]("AAAAABBBBBCCCCC".utf8)
        var compressed:[UInt8] = try CompressionTechnique.RunLengthEncoding(minRun: 3, alwaysIncludeRunCount: true).compress(data: data).data
        var expected_result:[UInt8] = [196, 65, 196, 66, 196, 67]
        #expect(compressed == expected_result)

        compressed = try CompressionTechnique.RunLengthEncoding(minRun: 5, alwaysIncludeRunCount: true).compress(data: data).data
        #expect(compressed == expected_result)

        compressed = try CompressionTechnique.RunLengthEncoding(minRun: 6, alwaysIncludeRunCount: true).compress(data: data).data
        #expect(compressed == expected_result)

        compressed = try CompressionTechnique.RunLengthEncoding(minRun: 6, alwaysIncludeRunCount: false).compress(data: data).data
        expected_result = data
        #expect(compressed == expected_result)

        data = [UInt8](String(repeating: "A", count: 66).utf8)
        compressed = try CompressionTechnique.RunLengthEncoding(minRun: 3, alwaysIncludeRunCount: true).compress(data: data).data
        expected_result = [255, 65, 193, 65]
        #expect(compressed == expected_result)

        data = [190, 191, 192]
        compressed = try CompressionTechnique.RunLengthEncoding(minRun: 3, alwaysIncludeRunCount: false).compress(data: data).data
        expected_result = [190, 191, 192, 192]
        #expect(compressed == expected_result)

        compressed = try CompressionTechnique.RunLengthEncoding(minRun: 3, alwaysIncludeRunCount: true).compress(data: data).data
        expected_result = [192, 190, 192, 191, 192, 192]
        #expect(compressed == expected_result)
    }
}

/*
// MARK: AsyncStream
extension RunLengthEncodingTests {
    @Test func compressRLEAsyncStream() async {
        var data:[UInt8] = [UInt8]("AAAAABBBBBCCCCC".utf8)
        var stream:AsyncStream<UInt8> = AsyncStream {
            CompressionTechnique.runLength(minRun: 3, alwaysIncludeRunCount: true).compress(data: data, continuation: $0)
            $0.finish()
        }
        var index:Int = 0
        var expected_result:[UInt8] = [196, 65, 196, 66, 196, 67]
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        stream = AsyncStream {
            CompressionTechnique.runLength(minRun: 5, alwaysIncludeRunCount: true).compress(data: data, continuation: $0)
            $0.finish()
        }
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        stream = AsyncStream {
            CompressionTechnique.runLength(minRun: 6, alwaysIncludeRunCount: true).compress(data: data, continuation: $0)
            $0.finish()
        }
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        stream = AsyncStream {
            CompressionTechnique.runLength(minRun: 6, alwaysIncludeRunCount: false).compress(data: data, continuation: $0)
            $0.finish()
        }
        expected_result = data
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        data = [UInt8](String(repeating: "A", count: 66).utf8)
        stream = AsyncStream {
            CompressionTechnique.runLength(minRun: 3, alwaysIncludeRunCount: true).compress(data: data, continuation: $0)
            $0.finish()
        }
        expected_result = [255, 65, 193, 65]
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        data = [190, 191, 192]
        stream = AsyncStream {
            CompressionTechnique.runLength(minRun: 3, alwaysIncludeRunCount: false).compress(data: data, continuation: $0)
            $0.finish()
        }
        expected_result = [190, 191, 192, 192]
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }

        index = 0
        stream = AsyncStream {
            CompressionTechnique.runLength(minRun: 3, alwaysIncludeRunCount: true).compress(data: data, continuation: $0)
            $0.finish()
        }
        expected_result = [192, 190, 192, 191, 192, 192]
        for await byte in stream {
            #expect(byte == expected_result[index])
            index += 1
        }
    }
}*/

// MARK: Decompress
extension RunLengthEncodingTests {
    @Test func decompressRLE() throws {
        let string:String = "AAAAABBBBBCCCCC"
        let data:[UInt8] = [UInt8](string.utf8)
        let compressed:[UInt8] = try CompressionTechnique.RunLengthEncoding(minRun: 3, alwaysIncludeRunCount: true).compress(data: data).data
        let decompressed:[UInt8] = try CompressionTechnique.RunLengthEncoding(minRun: 3, alwaysIncludeRunCount: true).decompress(data: compressed)
        #expect(decompressed == data)
    }
}

#endif