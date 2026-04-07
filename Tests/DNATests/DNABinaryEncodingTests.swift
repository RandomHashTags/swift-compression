
#if compiler(>=6.0)

import Testing
@testable import CompressionDNA
@testable import SwiftCompressionUtilities

struct DNABinaryEncodingTests {
    static let sequence = "TACTTGCTAAAAGTACATTGCTAAGATACACCGGCA"
    static let data = [UInt8](sequence.utf8)
    static let compressed = CompressionTechnique.dnaBinaryEncoding().compress(data: data, configuration: .init())

    @Test func compressDNABinaryEncoding() {
        #expect(Self.compressed == [199, 231, 0, 177, 62, 112, 140, 69, 164])
    }

    @Test func decompressDNABinaryEncoding() throws(DecompressionError) {
        let result = CompressionTechnique.dnaBinaryEncoding().decompress(data: Self.compressed, configuration: .init())
        #expect(result == Self.data)
    }
}

#endif