//
//  HuffmanTests.swift
//
//
//  Created by Evan Anderson on 12/17/24.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompression

struct HuffmanTests {
    static let scoobyDooString:String = "ruh roh raggy!"
    static let scoobyDoo:[UInt8] = [UInt8](scoobyDooString.utf8)
    static let scoobyDooCompressed:CompressionResult<[UInt8]> = CompressionTechnique.Huffman.compress(data: scoobyDoo)!
    
    @Test func compressHuffman() {
        let result:CompressionResult = Self.scoobyDooCompressed
        #expect(result.data == [4, 31, 67, 180, 23, 253, 96])
        #expect(result.validBitsInLastByte == 4)
    }

    @Test func decompressHuffman() {
        let result:CompressionResult = Self.scoobyDooCompressed
        let decompressed:[UInt8] = CompressionTechnique.huffman(rootNode: result.rootNode).decompress(data: result.data)
        #expect(result.validBitsInLastByte == 4)
        #expect(decompressed == Self.scoobyDoo)
    }

    @Test func decompressHuffmanOnlyFrequencyTable() {
        let result:CompressionResult = Self.scoobyDooCompressed
        let table:[Int] = Self.scoobyDooString.huffmanFrequencyTable()
        let decompressed:[UInt8] = CompressionTechnique.Huffman.decompress(data: result.data, frequencyTable: table)
        #expect(decompressed == Self.scoobyDoo)
    }
}

#endif