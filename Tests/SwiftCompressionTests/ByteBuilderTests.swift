
#if compiler(>=6.0)

import ByteBuilder
import Testing
@testable import SwiftCompressionUtilities

struct BytesBuilderTests {
    @Test
    func bytesBuilder() {
        var builder = BytesBuilder()
        builder.data.reserveCapacity(100)
        builder.write(amount: 4, bits: 1 | 4)
        #expect(builder.builder._bits == 5)

        builder.write(amount: 5, bits: 1 | 2 | 4 | 8 | 16)
        builder.finalize()
        var expected:[UInt8] =  [
            1 | 4 | 16 | 32 | 64 | 128,
            1
        ]
        #expect(builder.data == expected, "\(builder.data.map({ String($0, radix: 2) })) != \(expected.map({ String($0, radix: 2) }))")

        builder = .init()
        builder.write(amount: 8, bits: 8)
        builder.finalize()
        expected = [8]
        #expect(builder.data == expected)

        builder.write(amount: 2, bits: 1)
        builder.finalize()
        expected.append(1)
        #expect(builder.data == expected)
    }
}

#endif