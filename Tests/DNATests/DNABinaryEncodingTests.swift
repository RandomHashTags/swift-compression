//
//  BitTests.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

#if compiler(>=6.0)

import Testing
@testable import DNA
@testable import SwiftCompressionUtilities

struct DNABinaryEncodingTests {
    static let sequence:String = "TACTTGCTAAAAGTACATTGCTAAGATACACCGGCA"
    static let data:[UInt8] = [UInt8](sequence.utf8)
    static let compressed:CompressionResult = try! CompressionTechnique.dnaBinaryEncoding().compress(data: data)

    @Test func compressDNABinaryEncoding() {
        #expect(Self.compressed.data == [199, 231, 0, 177, 62, 112, 140, 69, 164])
    }

    @Test func decompressDNABinaryEncoding() throws(DecompressionError) {
        let result:[UInt8] = try CompressionTechnique.dnaBinaryEncoding().decompress(data: Self.compressed.data)
        #expect(result == Self.data)
    }
}

#endif