//
//  HuffmanTests.swift
//
//
//  Created by Evan Anderson on 12/17/24.
//

#if compiler(>=6.0)

#if canImport(Foundation)
import Foundation
#endif

import Testing
@testable import SwiftCompression

struct HuffmanTests {
    #if canImport(Foundation)
    @Test func compressHuffman() {
        var string:String = "ruh roh raggy!"
        var data:[UInt8] = [UInt8](string.data(using: .utf8)!)
        var result:CompressionResult = CompressionTechnique.Huffman.compress(data: data)
        //print("data=\(data)")
        //print("compressed=\(result.data)")
        var decompressed:[UInt8] = CompressionTechnique.huffman(rootNode: result.rootNode).decompress(data: result.data)
        //print("decompressed=\(decompressed) (\(String(data: Data(decompressed), encoding: .utf8)!))")
    }
    #endif
}

#endif