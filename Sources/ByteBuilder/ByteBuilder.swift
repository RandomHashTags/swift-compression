
// MARK: ByteBuilder
/// Outputs a byte (`UInt8`) when 8 bits are written or upon flush.
public struct ByteBuilder {
    package var _bits:UInt8 = 0
    package var index:UInt8 = 0

    public init() {
    }

    /// - Complexity: O(1).
    subscript(_ index: UInt8) -> Bool {
        get {
            assert(index < 8)
            return (_bits & (1 << index)) != 0
        }
        set {
            assert(index < 8)
            _bits = newValue ? _bits | (1 << index) : _bits & ~(1 << index)
        }
    }

    /// - Returns: The complete byte, if all 8 bits were filled.
    /// - Complexity: O(1).
    public mutating func write(bit: Bool) -> UInt8? {
        self[index] = bit
        index += 1
        let result:UInt8?
        if index == 8 {
            result = _bits
            clear()
        } else {
            result = nil
        }
        return result
    }

    /// - Complexity: O(1).
    /// - Warning: `amount` **MUST** be greater than 0 AND less than or equal to `8`!
    public mutating func write(
        amount: Int,
        bits: UInt8,
        closure: (UInt8) -> Void
    ) {
        assert(amount > 0)
        assert(amount <= 8)
        let appendMask = ~(UInt8.max << amount)
        let appendableBits = appendMask & bits

        let oldIndex = index
        index += UInt8(truncatingIfNeeded: amount)
        if index < 8 {
            _bits |= (appendableBits << oldIndex)
        } else if index == 8 {
            let result = _bits | (appendableBits << oldIndex)
            closure(result)
            _bits = 0
            index = 0
        } else { // index > 8
            _bits |= (appendableBits << oldIndex)
            closure(_bits)
            _bits = appendableBits >> (8 - oldIndex)
            index -= 8
        }
    }

    /// - Complexity: O(1). 
    public mutating func flush() -> (lastByte: UInt8, validBits: UInt8)? {
        guard index != 0 else { return nil }
        defer { clear() }
        return (_bits, index)
    }

    /// - Complexity: O(1).
    public mutating func flush(into data: inout [UInt8]) {
        guard let wrote = flush()?.lastByte else { return }
        data.append(wrote)
    }

    /// - Complexity: O(1).
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public mutating func flush(into stream: AsyncStream<UInt8>.Continuation) {
        guard let wrote = flush()?.lastByte else { return }
        stream.yield(wrote)
    }
    
    /// Assigns the `index` to zero and all bits to `false`.
    /// 
    /// - Complexity: O(1).
    public mutating func clear() {
        index = 0
        _bits = 0
    }
}
/*

// MARK: StreamBuilder
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public struct StreamBuilder {
    public var stream:AsyncStream<UInt8>.Continuation
    public var builder:ByteBuilder

    public init(stream: AsyncStream<UInt8>.Continuation, builder: ByteBuilder = ByteBuilder()) {
        self.stream = stream
        self.builder = builder
    }

    /// - Complexity: O(1).
    public mutating func write(bit: Bool) {
        if let wrote:UInt8 = builder.write(bit: bit) {
            stream.yield(wrote)
        }
    }

    /// - Complexity: O(1).
    public mutating func finalize() {
        builder.flush(into: stream)
    }
}
*/