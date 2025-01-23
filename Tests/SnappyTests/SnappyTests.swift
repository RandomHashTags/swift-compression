//
//  SnappyTests.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

#if compiler(>=6.0)

import Testing
@testable import Snappy
@testable import SwiftCompressionUtilities

struct SnappyTests {

    @Test func decompressSnappy() throws {
        let expected_result:String = "Wikipedia is a free, web-based, collaborative, multilingual encyclopedia project."
        var string:String = "51 f0 42 57 69 6b 69 70 65 64 69 61 20 69 73 20"
        string += "61 20 66 72 65 65 2c 20 77 65 62 2d 62 61 73 65"
        string += "64 2c 20 63 6f 6c 6c 61 62 6f 72 61 74 69 76 65"
        string += "2c 20 6d 75 6c 74 69 6c 69 6e 67 75 61 6c 20 65"
        string += "6e 63 79 63 6c 6f 09 3f 1c 70 72 6f 6a 65 63 74"
        string += "2e"
        string.removeAll(where: { $0.isWhitespace })
        let hex = string.hexadecimal
        let data:[UInt8] = [UInt8](hex)
        let decompressed:[UInt8] = try CompressionTechnique.snappy.decompress(data: data)
        #expect(decompressed == [UInt8](expected_result.utf8))
    }
}


#endif