
import Testing
@testable import CompressionDNA
@testable import SwiftCompressionUtilities

struct DNABinaryEncodingTests {
    static let sequence = "TACTTGCTAAAAGTACATTGCTAAGATACACCGGCA"
    static let data = [UInt8](sequence.utf8)
    static let compressed = DNABinaryEncoding().compress(data: data, configuration: .init())

    @Test
    func compressDNABinaryEncoding() {
        let expected:[UInt8] = [211, 219, 0, 78, 188, 13, 50, 81, 26]
        let compressedBinary = Self.compressed.map({ String($0, radix: 2) })
        let expectedCompressedBinary = expected.map({ String($0, radix: 2) })
        #expect(Self.compressed == expected, "\(compressedBinary) != \(expectedCompressedBinary)")
    }

    @Test
    func decompressDNABinaryEncoding() throws(DecompressionError) {
        let result = DNABinaryEncoding().decompress(data: Self.compressed, configuration: .init())
        #expect(result == Self.data)
    }
}