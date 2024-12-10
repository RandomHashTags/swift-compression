//
//  IntExtensions.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

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
        self = fromBits.reduce(0) { 2 * $0 + ($1 == true ? 1 : 0) }
    }
}