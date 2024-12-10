//
//  IntExtensions.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

typealias Bits8 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)
typealias Bits16 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)

extension FixedWidthInteger {
    var bits : [Bool] {
        var int:Self = self
        var bits:[Bool] = Array(repeating: false, count: bitWidth)
        for i in stride(from: bitWidth-1, through: 0, by: -1) {
            bits[i] = int & 0x01 == 1
            int >>= 1
        }
        return bits
    }

    init?(fromBits: [Bool]) {
        guard fromBits.count <= Self.bitWidth else { return nil }
        self = fromBits.reduce(0) { 2 * $0 + ($1 ? 1 : 0) }
    }
}

extension UInt8 {
    var bitsTuple : Bits8 {
        var int:Self = self
        let v7:Bool = int & 0x01 == 1
        int >>= 1
        let v6:Bool = int & 0x01 == 1
        int >>= 1
        let v5:Bool = int & 0x01 == 1
        int >>= 1
        let v4:Bool = int & 0x01 == 1
        int >>= 1
        let v3:Bool = int & 0x01 == 1
        int >>= 1
        let v2:Bool = int & 0x01 == 1
        int >>= 1
        let v1:Bool = int & 0x01 == 1
        int >>= 1
        let v0:Bool = int & 0x01 == 1
        return (v0, v1, v2, v3, v4, v5, v6, v7)
    }
    var bitsTupleReverse : Bits8 {
        var int:Self = self
        let v7:Bool = int & 0x01 == 1
        int >>= 1
        let v6:Bool = int & 0x01 == 1
        int >>= 1
        let v5:Bool = int & 0x01 == 1
        int >>= 1
        let v4:Bool = int & 0x01 == 1
        int >>= 1
        let v3:Bool = int & 0x01 == 1
        int >>= 1
        let v2:Bool = int & 0x01 == 1
        int >>= 1
        let v1:Bool = int & 0x01 == 1
        int >>= 1
        let v0:Bool = int & 0x01 == 1
        return (v7, v6, v5, v4, v3, v2, v1, v0)
    }

    init(fromBits: Bits8) {
        self = (fromBits.0 ? 128 : 0) + (fromBits.1 ? 64 : 0) + (fromBits.2 ? 32 : 0) + (fromBits.3 ? 16 : 0) + (fromBits.4 ? 8 : 0) + (fromBits.5 ? 4 : 0) + (fromBits.6 ? 2 : 0) + (fromBits.7 ? 1 : 0)
    }
}