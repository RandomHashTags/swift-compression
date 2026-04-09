
#if compiler(>=6.0)

import Huffman
import Testing

struct HuffmanTests {
    static let scoobyDooString = "ruh roh raggy!"
    static let scoobyDoo:[UInt8] = .init(scoobyDooString.utf8)
    static let scoobyDooCompressed = Huffman().compress(data: scoobyDoo, configuration: .default)!
    
    @Test func compressHuffman() {
        let result = Self.scoobyDooCompressed
        #expect(result.data == [4, 31, 67, 180, 23, 253, 96])
        #expect(result.validBitsInLastByte == 4)
    }

    @Test func decompressHuffman() {
        let result = Self.scoobyDooCompressed
        let decompressed = Huffman().decompress(data: result.data, configuration: .init(root: result.rootNode))
        #expect(result.validBitsInLastByte == 4)
        #expect(decompressed == Self.scoobyDoo)
    }

    @Test func decompressHuffmanOnlyFrequencyTable() {
        let result = Self.scoobyDooCompressed
        let table = Self.scoobyDooString.huffmanFrequencyTable()
        let decompressed = Huffman().decompress(data: result.data, frequencyTable: table)
        #expect(decompressed == Self.scoobyDoo)
    }
}

#endif