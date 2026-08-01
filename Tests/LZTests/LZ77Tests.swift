
#if compiler(>=6.0)

@testable import CompressionLZ
@testable import SwiftCompressionUtilities
import Testing

struct LZ77Tests {
    static let string:String = "abracadabra abracadabra"
    static let lz77 = LZ77<UInt16>(windowSize: 10, bufferSize: 6)
    static let compressed = lz77.compress([UInt8](string.utf8), configuration: .init(reserveCapacity: 1024))

    @Test func compressLZ77() {
        #expect(Self.compressed == [
            0, 0, 0, 97, 0, 0, 0, 98, 0, 0, 0, 114, 0, 3, 1, 99, 0, 5, 1, 100, 0, 7, 4, 32, 0, 5, 4, 99, 0, 10, 1, 100, 0, 7, 4, 0
        ])
    }
    @Test func decompressLZ77() throws(DecompressionError) {
        let result = Self.lz77.decompress(data: Self.compressed, configuration: .init(reserveCapacity: 1024))
        #expect(result == [UInt8](Self.string.utf8))
    }
}

#endif