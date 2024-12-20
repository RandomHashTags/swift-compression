//
//  BitTests.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompression

struct DNABinaryEncodingTests {
    static let sequence:String = "TACTTGCTAAAAGTACATTGCTAAGATACACCGGCA"
    static let data:[UInt8] = [UInt8](sequence.utf8)
    static let compressed:CompressionResult = CompressionTechnique.DNABinaryEncoding.compress(data: data)

    @Test func compressDNABinaryEncoding() {
        #expect(Self.compressed.data == [199, 231, 0, 177, 62, 112, 140, 69, 164])
    }

    @Test func decompressDNABinaryEncoding() {
        let result:[UInt8] = CompressionTechnique.DNABinaryEncoding.decompress(data: Self.compressed.data)
        #expect(result == Self.data)
    }
}

#endif