
import Testing
@testable import SwiftCompressionUtilities

struct BitTests {
    @Test(arguments: [
        (UInt8(0),   [Bool]([false, false, false, false, false, false, false, false])),
        (UInt8(1),   [Bool]([true, false, false, false, false, false, false, false])),
        (UInt8(2),   [Bool]([false, true, false, false, false, false, false, false])),
        (UInt8(3),   [Bool]([true, true, false, false, false, false, false, false])),
        (UInt8(4),   [Bool]([false, false, true, false, false, false, false, false])),
        (UInt8(8),   [Bool]([false, false, false, true, false, false, false, false])),
        (UInt8(16),  [Bool]([false, false, false, false, true, false, false, false])),
        (UInt8(32),  [Bool]([false, false, false, false, false, true, false, false])),
        (UInt8(64),  [Bool]([false, false, false, false, false, false, true, false])),
        (UInt8(128), [Bool]([false, false, false, false, false, false, false, true])),
        (UInt8(255), [Bool]([true, true, true, true, true, true, true, true]))
    ])
    func uint8Bits(
        int: UInt8,
        expectedBits: [Bool]
    ) {
        #expect(int.bits == expectedBits)

        #expect(UInt8(fromBits: [false]) == 0)
        #expect(UInt8(fromBits: [false, false, false, false, false, false, false, false]) == 0)
        #expect(UInt8(fromBits: [true, false]) == 2)      
        #expect(UInt8(fromBits: [true, false, false, false, false, false, false, false])  == 128)

        #expect(UInt32(fromBits: .max, 0, 0) == 16711680)
    }
    @Test func uint16Bits() {
        var int:UInt16 = 0
        var expected_result:[Bool] = Array(repeating: false, count: 16)
        #expect(int.bits == expected_result)

        int = 2
        expected_result[14] = true
        #expect(int.bits == expected_result.reversed())

        int = 4
        expected_result[14] = false
        expected_result[13] = true
        #expect(int.bits == expected_result.reversed())

        int = 8
        expected_result[13] = false
        expected_result[12] = true
        #expect(int.bits == expected_result.reversed())

        int = 16
        expected_result[12] = false
        expected_result[11] = true
        #expect(int.bits == expected_result.reversed())

        int = 32
        expected_result[11] = false
        expected_result[10] = true
        #expect(int.bits == expected_result.reversed())

        int = 64
        expected_result[10] = false
        expected_result[9] = true
        #expect(int.bits == expected_result.reversed())

        int = 128
        expected_result[9] = false
        expected_result[8] = true
        #expect(int.bits == expected_result.reversed())

        int = 256
        expected_result[8] = false
        expected_result[7] = true
        #expect(int.bits == expected_result.reversed())

        int = 512
        expected_result[7] = false
        expected_result[6] = true
        #expect(int.bits == expected_result.reversed())

        int = 1024
        expected_result[6] = false
        expected_result[5] = true
        #expect(int.bits == expected_result.reversed())

        int = 2048
        expected_result[5] = false
        expected_result[4] = true
        #expect(int.bits == expected_result.reversed())

        int = 4096
        expected_result[4] = false
        expected_result[3] = true
        #expect(int.bits == expected_result.reversed())

        int = 8192
        expected_result[3] = false
        expected_result[2] = true
        #expect(int.bits == expected_result.reversed())

        int = 16384
        expected_result[2] = false
        expected_result[1] = true
        #expect(int.bits == expected_result.reversed())

        int = 32768
        expected_result[1] = false
        expected_result[0] = true
        #expect(int.bits == expected_result.reversed())

        int = 65535
        expected_result = Array(repeating: true, count: 16)
        #expect(int.bits == expected_result)
    }
}