
#if compiler(>=6.0) && canImport(FoundationEssentials)

import FoundationEssentials
import Testing
@testable import Zlib

struct GzipTests {
    @Test
    func gzipTest() {
        let gzip = Gzip()
        let bro = "What in tarnation fornication trepidation what what what what what the the the the"
        let broData = bro.data(using: .utf8)!
        var compressed = gzip.compress(data: [UInt8](broData))!
        var decompressed = gzip.decompress(data: compressed)!
        decompressed.append(0)
        #expect(String(cString: decompressed) == bro)
    }
}

#endif