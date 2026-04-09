
#if compiler(>=6.0)

import ByteBuilder
import Testing
@testable import SwiftCompressionUtilities

struct BytesBuilderTests {
    @Test func bytesBuilder() {
        var builder = BytesBuilder()
        builder.data.reserveCapacity(100)
        builder.write(bits: [true, false, true, false])
        builder.write(bits: [true, true, true, true, true])
        builder.finalize()
        #expect(builder.data == [175, 128])
    }
}

#endif