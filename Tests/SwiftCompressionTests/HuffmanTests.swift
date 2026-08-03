
import Huffman
import Testing

struct HuffmanTests {
    static let scoobyDooString = "ruh roh raggy!"
    static let scoobyDoo:[UInt8] = .init(scoobyDooString.utf8)
    static let scoobyDooCompressed = Huffman().compress(scoobyDoo, configuration: .default)!
    
    @Test
    func compressHuffman() {
        let expected:[UInt8] = [4, 248, 194, 45, 232, 191, 6]
        let result = Self.scoobyDooCompressed
        #expect(result.data == expected, "\(result.data.map({ String($0, radix: 2) })) != \(expected.map({ String($0, radix: 2) }))")
        #expect(result.validBitsInLastByte == 4)
    }

    @Test
    func decompressHuffman() {
        let result = Self.scoobyDooCompressed
        let decompressed = Huffman().decompress(data: result.data, configuration: .init(root: result.rootNode))
        #expect(result.validBitsInLastByte == 4)
        #expect(decompressed == Self.scoobyDoo)
    }

    @Test
    func decompressHuffmanOnlyFrequencyTable() {
        let result = Self.scoobyDooCompressed
        let table = Self.scoobyDooString.huffmanFrequencyTable()
        let decompressed = Huffman().decompress(result.data, frequencyTable: table)
        #expect(decompressed == Self.scoobyDoo)
    }
}