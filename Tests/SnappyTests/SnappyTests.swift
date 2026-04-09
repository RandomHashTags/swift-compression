
#if compiler(>=6.0)

import Testing
@testable import Snappy
@testable import SwiftCompressionUtilities

struct SnappyTests {

    static let wikipedia:String = "Wikipedia is a free, web-based, collaborative, multilingual encyclopedia project."
    static let wikipediaHexadecimalLiteral:String = "51F05057696B697065646961206973206120667265652C207765622D62617365642C20636F6C6C61626F7261746976652C206D756C74696C696E6775616C20656E6379636C6F70656469612070726F6A6563742E"
    static let wikipediaHexadecimal:UnfoldSequence<UInt8, String.Index> = wikipediaHexadecimalLiteral.hexadecimal
    static let wikipediaCompressedData:[UInt8] = .init(wikipediaHexadecimal)

    @Test func compressSnappy() throws(CompressionError) {
        guard let compressed:[UInt8] = Snappy().compress(span: Self.wikipedia.utf8Span.span, configuration: .init()) else {
            #expect(Bool(false))
            return
        }
        #expect(compressed == Self.wikipediaCompressedData)

        guard var decompressed = try? Snappy().decompress(data: compressed) else {
            #expect(Bool(false))
            return
        }
        decompressed.append(0)
        #expect(String(cString: decompressed) == Self.wikipedia)
    }

    @Test func decompressSnappyLength() throws(DecompressionError) {
        let snappy = Snappy()
        var data:[UInt8] = [254, 255, 127]
        var index = data.startIndex
        var length:UInt32 = try snappy.decompressLength(data: data, index: &index)
        #expect(length == 2097150)

        for i in 0...127 {
            data = [UInt8(i)]
            index = data.startIndex
            length = try snappy.decompressLength(data: data, index: &index)
            #expect(length == i)
        }

        for i in 128...255 {
            data = [UInt8(i), 1]
            index = data.startIndex
            length = try snappy.decompressLength(data: data, index: &index)
            #expect(length == i)
        }
    }

    @Test func decompressSnappy() throws(DecompressionError) {
        let decompressed = try Snappy().decompress(data: Self.wikipediaCompressedData)
        #expect(decompressed == [UInt8](Self.wikipedia.utf8))
    }
}


#endif