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

    static let wikipedia:String = "Wikipedia is a free, web-based, collaborative, multilingual encyclopedia project."
    static let wikipediaHexadecimalLiteral:String = "51f04257696b697065646961206973206120667265652c207765622d62617365642c20636f6c6c61626f7261746976652c206d756c74696c696e6775616c20656e6379636c6f093f1c70726f6a6563742e"
    static let wikipediaHexadecimal:UnfoldSequence<UInt8, String.Index> = wikipediaHexadecimalLiteral.hexadecimal
    static let wikipediaCompressedData:[UInt8] = [UInt8](wikipediaHexadecimal)

    @Test func compressSnappy() throws(CompressionError) {
        let compressed:[UInt8] = try Self.wikipedia.compressed(using: CompressionTechnique.snappy()).data
        #expect(compressed == Self.wikipediaCompressedData)
    }

    @Test func decompressSnappy() throws(DecompressionError) {
        print("wikipediaCompressedData=\(Self.wikipediaCompressedData)")
        let decompressed:[UInt8] = try CompressionTechnique.snappy().decompress(data: Self.wikipediaCompressedData)
        #expect(decompressed == [UInt8](Self.wikipedia.utf8))
    }
}


#endif