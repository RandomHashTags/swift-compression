
#if canImport(FoundationEssentials)

import FoundationEssentials
import Testing
@testable import Brotli

struct BrotliTests {
    @Test
    func brotliTest() {
        let brotli = Brotli()
        let bro = "What in tarnation fornication trepidation what what what what what the the the the"
        let broData = bro.data(using: .utf8)!
        let compressed = brotli.compress(data: [UInt8](broData), configuration: .default)!
        guard var decompressed = brotli.decompress(data: compressed, configuration: .default) else {
            #expect(Bool(false))
            return
        }
        decompressed.append(0)
        #expect(String(cString: decompressed) == bro)
    }
}

#endif