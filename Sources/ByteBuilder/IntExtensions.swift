
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
}