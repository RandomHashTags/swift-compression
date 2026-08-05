
import ByteBuilder
import Testing
@testable import SwiftCompressionUtilities

struct ByteBuilderTests {
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

        builder = .init()
        builder.write(amount: 64, bits: UInt64.max)
        builder.finalize()
        expected = .init(repeating: .max, count: 8)
        #expect(builder.data == expected)
    }
}

extension ByteBuilderTests {
    @Test(arguments: [
        (0, 1),
        (1, 1),
        (2, 2),
        (3, 2),
        (4, 3),
        (5, 3),
        (6, 3),
        (7, 3),
        (8, 4),
        (16, 5),
        (31, 5),
        (32, 6),
        (63, 6),
        (64, 7),
        (128, 8),
        (254, 8),
        (255, 8),
        (256, 9),
        (510, 9),
        (511, 9),
        (512, 10),
        (513, 10),
        (4095, 12),
        (4096, 13)
    ])
    func minBitsRequiredToRepresent(
        number: Int,
        expected: Int
    ) {
        #expect(number.minBitsRequiredToRepresent == expected)
    }
}