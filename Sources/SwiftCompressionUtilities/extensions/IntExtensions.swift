//
//  IntExtensions.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public typealias Bits8 = (Bool, Bool, Bool, Bool, Bool, Bool, Bool, Bool)

extension FixedWidthInteger {
    /// - Complexity: O(_n_) where _n_ is `bitWidth`.
    @inlinable
    public var bits : [Bool] {
        var int = self
        var bits:[Bool] = .init(repeating: false, count: bitWidth)
        for i in stride(from: bitWidth-1, through: 0, by: -1) {
            bits[i] = int & 0x01 == 1
            int >>= 1
        }
        return bits
    }

    /// - Complexity: O(1).
    @inlinable
    public var bytes : [UInt8] {
        return withUnsafeBytes(of: self, Array.init)
    }

    /// - Complexity: O(1).
    @inlinable
    public var reversedBytes : ReversedCollection<[UInt8]> {
        return withUnsafeBytes(of: self, Array.init).reversed()
    }

    /// - Parameters:
    ///   - fromBits: Bits to assign.
    /// - Complexity: O(_n_) where _n_ is the length of `fromBits`.
    @inlinable
    public init?(fromBits: [Bool]) {
        guard fromBits.count <= Self.bitWidth else { return nil }
        self = fromBits.reduce(0) { 2 * $0 + ($1 ? 1 : 0) }
    }
    @inlinable
    public init(fromBits: Bits8) {
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
    @inlinable
    public init(fromBits: UInt8...) {
        var value:Self = 0
        var offset = Self.bitWidth - ((fromBits.count - 1) * 8)
        for bitBlock in fromBits {
            value |= Self(bitBlock) << (Self.bitWidth - offset)
            offset += 8
        }
        self = value
    }
}