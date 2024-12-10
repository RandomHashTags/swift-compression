//
//  BitTests.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation
import Testing
@testable import SwiftCompression

struct BitTests {
    @Test func uint8Bits() {
        var int:UInt8 = 0
        #expect(int.bits == [false, false, false, false, false, false, false, false])

        int = 1
        #expect(int.bits == [false, false, false, false, false, false, false, true])

        int = 2
        #expect(int.bits == [false, false, false, false, false, false, true, false])

        int = 3
        #expect(int.bits == [false, false, false, false, false, false, true, true])

        int = 4
        #expect(int.bits == [false, false, false, false, false, true, false, false])

        int = 8
        #expect(int.bits == [false, false, false, false, true, false, false, false])

        int = 16
        #expect(int.bits == [false, false, false, true, false, false, false, false])

        int = 32
        #expect(int.bits == [false, false, true, false, false, false, false, false])

        int = 64
        #expect(int.bits == [false, true, false, false, false, false, false, false])

        int = 128
        #expect(int.bits == [true, false, false, false, false, false, false, false])

        int = 255
        #expect(int.bits == [true, true, true, true, true, true, true, true])

        #expect(UInt8(fromBits: [false]) == 0)
        #expect(UInt8(fromBits: [false, false, false, false, false, false, false, false]) == 0)
        #expect(UInt8(fromBits: [true, false]) == 2)      
        #expect(UInt8(fromBits: [true, false, false, false, false, false, false, false])  == 128)
    }
    @Test func uint8BitsTuple() {
        var int:UInt8 = 0
        var value:Bits8 = int.bitsTuple
        #expect(!value.0)
        #expect(!value.1)
        #expect(!value.2)
        #expect(!value.3)
        #expect(!value.4)
        #expect(!value.5)
        #expect(!value.6)
        #expect(!value.7)
        #expect(UInt8(fromBits: value) == 0)

        int = 1
        value = int.bitsTuple
        #expect(!value.0)
        #expect(!value.1)
        #expect(!value.2)
        #expect(!value.3)
        #expect(!value.4)
        #expect(!value.5)
        #expect(!value.6)
        #expect(value.7)
        #expect(UInt8(fromBits: value) == 1)

        int = 255
        value = int.bitsTuple
        #expect(value.0)
        #expect(value.1)
        #expect(value.2)
        #expect(value.3)
        #expect(value.4)
        #expect(value.5)
        #expect(value.6)
        #expect(value.7)
        #expect(UInt8(fromBits: value) == 255)
    }
    @Test func uint16Bits() {
        var int:UInt16 = 0
        var expected_result:[Bool] = Array(repeating: false, count: 16)
        #expect(int.bits == expected_result)

        int = 2
        expected_result[14] = true
        #expect(int.bits == expected_result)

        int = 4
        expected_result[14] = false
        expected_result[13] = true
        #expect(int.bits == expected_result)

        int = 8
        expected_result[13] = false
        expected_result[12] = true
        #expect(int.bits == expected_result)

        int = 16
        expected_result[12] = false
        expected_result[11] = true
        #expect(int.bits == expected_result)

        int = 32
        expected_result[11] = false
        expected_result[10] = true
        #expect(int.bits == expected_result)

        int = 64
        expected_result[10] = false
        expected_result[9] = true
        #expect(int.bits == expected_result)

        int = 128
        expected_result[9] = false
        expected_result[8] = true
        #expect(int.bits == expected_result)

        int = 256
        expected_result[8] = false
        expected_result[7] = true
        #expect(int.bits == expected_result)

        int = 512
        expected_result[7] = false
        expected_result[6] = true
        #expect(int.bits == expected_result)

        int = 1024
        expected_result[6] = false
        expected_result[5] = true
        #expect(int.bits == expected_result)

        int = 2048
        expected_result[5] = false
        expected_result[4] = true
        #expect(int.bits == expected_result)

        int = 4096
        expected_result[4] = false
        expected_result[3] = true
        #expect(int.bits == expected_result)

        int = 8192
        expected_result[3] = false
        expected_result[2] = true
        #expect(int.bits == expected_result)

        int = 16384
        expected_result[2] = false
        expected_result[1] = true
        #expect(int.bits == expected_result)

        int = 32768
        expected_result[1] = false
        expected_result[0] = true
        #expect(int.bits == expected_result)

        int = 65535
        expected_result = Array(repeating: true, count: 16)
        #expect(int.bits == expected_result)
    }
}