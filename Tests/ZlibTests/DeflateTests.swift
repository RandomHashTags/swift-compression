
import Testing
@testable import Zlib

struct DeflateTests {
    @Test
    func deflateTest() {
        let deflate = Deflate()
        let bro = "What in tarnation fornication trepidation what what what what what the the the the"
        let broData = bro.data(using: .utf8)!
        var compressed = deflate.compress(data: [UInt8](broData))!
        var decompressed = deflate.decompress(data: compressed.data)!
        decompressed.append(0)
        #expect(String(cString: decompressed) == bro)
    }
}