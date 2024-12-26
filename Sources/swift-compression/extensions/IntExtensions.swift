//
//  IntExtensions.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public typealias Bits2 = (Bool, Bool)
public typealias Bits3 = (Bool, Bool, Bool)
public typealias Bits4 = (Bool, Bool, Bool, Bool)
public typealias Bits6 = (Bool, Bool, Bool, Bool, Bool, Bool)
public typealias Bits8 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)
public typealias Bits11 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)
public typealias Bits16 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)
public typealias Bits24 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)
public typealias Bits32 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)

public extension FixedWidthInteger {
    /// - Complexity: O(_n_) where _n_ is `bitWidth`.
    var bits : [Bool] {
        var int:Self = self
        var bits:[Bool] = Array(repeating: false, count: bitWidth)
        for i in stride(from: bitWidth-1, through: 0, by: -1) {
            bits[i] = int & 0x01 == 1
            int >>= 1
        }
        return bits
    }

    /// - Complexity: O(1).
    var bytes : [UInt8] {
        return withUnsafeBytes(of: self, Array.init)
    }

    /// - Complexity: O(1).
    var reversedBytes : ReversedCollection<[UInt8]> {
        return withUnsafeBytes(of: self, Array.init).reversed()
    }

    /// - Parameters:
    ///   - fromBits: The bits to assign.
    /// - Complexity: O(_n_) where _n_ is the length of `fromBits`.
    init?(fromBits: [Bool]) {
        guard fromBits.count <= Self.bitWidth else { return nil }
        self = fromBits.reduce(0) { 2 * $0 + ($1 ? 1 : 0) }
    }

    init(fromBits: Bits2) {
        self = (fromBits.0 ? 2 : 0) + (fromBits.1 ? 1 : 0)
    }
    init(fromBits: Bits3) {
        self = (fromBits.0 ? 4 : 0) + (fromBits.1 ? 2 : 0) + (fromBits.2 ? 1 : 0)
    }
    init(fromBits: Bits4) {
        self = (fromBits.0 ? 8 : 0) + (fromBits.1 ? 4 : 0) + (fromBits.2 ? 2 : 0) + (fromBits.3 ? 1 : 0)
    }
    init(fromBits: Bits6) {
        self = (fromBits.0 ? 32 : 0) + (fromBits.1 ? 16 : 0) + (fromBits.2 ? 8 : 0) + (fromBits.3 ? 4 : 0) + (fromBits.4 ? 2 : 0) + (fromBits.5 ? 1 : 0)
    }
    init(highBits: Bits4, lowBits: Bits4) {
        var value:Self = 0
        if highBits.0 { value += 128 }
        if highBits.1 { value += 64 }
        if highBits.2 { value += 32 }
        if highBits.3 { value += 16 }
        if lowBits.0 { value += 8 }
        if lowBits.1 { value += 4 }
        if lowBits.2 { value += 2 }
        if lowBits.3 { value += 1 }
        self = value
    }
    init(fromBits: Bits8) {
        var value:Self = 0
        if fromBits.0 { value += 128 }
        if fromBits.1 { value += 64 }
        if fromBits.2 { value += 32 }
        if fromBits.3 { value += 16 }
        if fromBits.4 { value += 8 }
        if fromBits.5 { value += 4 }
        if fromBits.6 { value += 2 }
        if fromBits.7 { value += 1 }
        self = value
    }
    init(fromBits: Bits11) {
        var value:Self = 0
        if fromBits.0  { value += 1024 }
        if fromBits.1  { value += 512 }
        if fromBits.2  { value += 256 }
        if fromBits.3  { value += 128 }
        if fromBits.4  { value += 64 }
        if fromBits.5  { value += 32 }
        if fromBits.6  { value += 16 }
        if fromBits.7  { value += 8 }
        if fromBits.8  { value += 4 }
        if fromBits.9  { value += 2 }
        if fromBits.10 { value += 1 }
        self = value
    }
    init(highBits: Bits8, lowBits: Bits8) {
        var value:Self = 0
        if highBits.0 { value += 32768 }
        if highBits.1 { value += 16384 }
        if highBits.2 { value += 8192 }
        if highBits.3 { value += 4096 }
        if highBits.4 { value += 2048 }
        if highBits.5 { value += 1024 }
        if highBits.6 { value += 512 }
        if highBits.7 { value += 256 }
        if lowBits.0  { value += 128 }
        if lowBits.1  { value += 64 }
        if lowBits.2  { value += 32 }
        if lowBits.3  { value += 16 }
        if lowBits.4  { value += 8 }
        if lowBits.5  { value += 4 }
        if lowBits.6  { value += 2 }
        if lowBits.7  { value += 1 }
        self = value
    }
    init(fromBits: Bits16) {
        var value:Self = 0
        if fromBits.0  { value += 32768 }
        if fromBits.1  { value += 16384 }
        if fromBits.2  { value += 8192 }
        if fromBits.3  { value += 4096 }
        if fromBits.4  { value += 2048 }
        if fromBits.5  { value += 1024 }
        if fromBits.6  { value += 512 }
        if fromBits.7  { value += 256 }
        if fromBits.8  { value += 128 }
        if fromBits.9  { value += 64 }
        if fromBits.10 { value += 32 }
        if fromBits.11 { value += 16 }
        if fromBits.12 { value += 8 }
        if fromBits.13 { value += 4 }
        if fromBits.14 { value += 2 }
        if fromBits.15 { value += 1 }
        self = value
    }
    init(fromBits: Bits24) {
        var value:Self = 0
        if fromBits.0  { value += 8388608 }
        if fromBits.1  { value += 4194304 }
        if fromBits.2  { value += 2097152 }
        if fromBits.3  { value += 1048576 }
        if fromBits.4  { value += 524288 }
        if fromBits.5  { value += 262144 }
        if fromBits.6  { value += 131072 }
        if fromBits.7  { value += 65536 }
        if fromBits.8  { value += 32768 }
        if fromBits.9  { value += 16384 }
        if fromBits.10 { value += 8192 }
        if fromBits.11 { value += 4096 }
        if fromBits.12 { value += 2048 }
        if fromBits.13 { value += 1024 }
        if fromBits.14 { value += 512 }
        if fromBits.15 { value += 256 }
        if fromBits.16 { value += 128 }
        if fromBits.17 { value += 64 }
        if fromBits.18 { value += 32 }
        if fromBits.19 { value += 16 }
        if fromBits.20 { value += 8 }
        if fromBits.21 { value += 4 }
        if fromBits.22 { value += 2 }
        if fromBits.23 { value += 1 }
        self = value
    }
    init(fromBits: Bits32) {
        var value:Self = 0
        if fromBits.0  { value += 2147483648 }
        if fromBits.1  { value += 1073741824 }
        if fromBits.2  { value += 536870912 }
        if fromBits.3  { value += 268435456 }
        if fromBits.4  { value += 134217728 }
        if fromBits.5  { value += 67108864 }
        if fromBits.6  { value += 33554432 }
        if fromBits.7  { value += 16777216 }
        if fromBits.8  { value += 8388608 }
        if fromBits.9  { value += 4194304 }
        if fromBits.10 { value += 2097152 }
        if fromBits.11 { value += 1048576 }
        if fromBits.12 { value += 524288 }
        if fromBits.13 { value += 262144 }
        if fromBits.14 { value += 131072 }
        if fromBits.15 { value += 65536 }
        if fromBits.16 { value += 32768 }
        if fromBits.17 { value += 16384 }
        if fromBits.18 { value += 8192 }
        if fromBits.19 { value += 4096 }
        if fromBits.20 { value += 2048 }
        if fromBits.21 { value += 1024 }
        if fromBits.22 { value += 512 }
        if fromBits.23 { value += 256 }
        if fromBits.24 { value += 128 }
        if fromBits.25 { value += 64 }
        if fromBits.26 { value += 32 }
        if fromBits.27 { value += 16 }
        if fromBits.28 { value += 8 }
        if fromBits.29 { value += 4 }
        if fromBits.30 { value += 2 }
        if fromBits.31 { value += 1 }
        self = value
    }
}
public extension UInt16 {
    init(_ b0: Bits8, _ b1: Bits8) {
        self = Self(UInt8(fromBits: b0)) + Self(UInt8(fromBits: b1))
    }
}
public extension UInt32 {
    init(_ b0: Bits8, _ b1: Bits8, _ b2: Bits8, _ b3: Bits8) {
        self = Self(UInt16(highBits: b0, lowBits: b1)) + Self(UInt16(highBits: b2, lowBits: b3))
    }
}
public extension UInt64 {
    init(_ b0: Bits8, _ b1: Bits8, _ b2: Bits8, _ b3: Bits8, _ b4: Bits8, _ b5: Bits8, _ b6: Bits8, _ b7: Bits8) {
        self = Self(UInt32(b0, b1, b2, b3)) + Self(UInt32(b4, b5, b6, b7))
    }
}

public extension UInt8 {
    /// - Complexity: O(1).
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
    
    /// - Complexity: O(1).
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
}