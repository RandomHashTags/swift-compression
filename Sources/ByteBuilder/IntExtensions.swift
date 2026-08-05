
extension FixedWidthInteger {
    public init(fromBits: UInt8...) {
        var value:Self = 0
        var offset = Self.bitWidth - ((fromBits.count - 1) * 8)
        for bitBlock in fromBits {
            value |= Self(bitBlock) << (Self.bitWidth - offset)
            offset += 8
        }
        self = value
    }

    /// - Warning: `self` **MUST NOT** be negative!
    package var minBitsRequiredToRepresent: Int {
        assert(self >= 0)
        let v = bitWidth - leadingZeroBitCount
        return Swift.max(1, v)
    }
}