//
//  ByteBuilder.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

// MARK: ByteBuilder
/// Outputs a byte (`UInt8`) when 8 bits are written or upon flush.
public struct ByteBuilder {
    public var bits:Bits8 = (false, false, false, false, false, false, false, false)
    public var index:UInt8 = 0

    public init() {
    }

    /// - Complexity: O(1)
    @inlinable
    subscript(_ index: UInt8) -> Bool {
        get {
            switch index {
            case 0: return bits.0
            case 1: return bits.1
            case 2: return bits.2
            case 3: return bits.3
            case 4: return bits.4
            case 5: return bits.5
            case 6: return bits.6
            case 7: return bits.7
            default: return false
            }
        }
        set {
            switch index {
            case 0: bits.0 = newValue
            case 1: bits.1 = newValue
            case 2: bits.2 = newValue
            case 3: bits.3 = newValue
            case 4: bits.4 = newValue
            case 5: bits.5 = newValue
            case 6: bits.6 = newValue
            case 7: bits.7 = newValue
            default: break
            }
        }
    }

    /// - Returns: The complete byte, if all 8 bits are filled.
    /// - Complexity: O(1)
    @inlinable
    public mutating func write(bit: Bool) -> UInt8? {
        self[index] = bit
        index += 1
        let result:UInt8?
        if index == 8 {
            result = UInt8(fromBits: self.bits)
            clear()
        } else {
            result = nil
        }
        return result
    }

    @inlinable
    public mutating func write(bits: [Bool], closure: (UInt8) -> Void) {
        let available_bits:UInt8 = UInt8(min(Int(8 - index), bits.count))
        for i in 0..<available_bits {
            self[index + i] = bits[Int(i)]
        }
        index += available_bits
        guard index == 8 else { return }

        closure(UInt8(fromBits: self.bits))
        clear()

        var remaining:Int = bits.count - Int(available_bits)
        let blocks:Int = remaining / 8, offset:Int = blocks * 8
        remaining -= offset
        for block in 0..<blocks {
            let blockIndex:Int = block * 8
            closure(UInt8(fromBits: (
                bits[blockIndex],
                bits[blockIndex + 1],
                bits[blockIndex + 2],
                bits[blockIndex + 3],
                bits[blockIndex + 4],
                bits[blockIndex + 5],
                bits[blockIndex + 6],
                bits[blockIndex + 7]
            )))
        }
        if remaining != 0 {
            let last_bits:UInt8 = UInt8(remaining)
            for i in 0..<last_bits {
                self[index + i] = bits[offset + Int(i)]
            }
            index += last_bits
        }
    }

    /// - Complexity: O(1). 
    @inlinable
    public mutating func flush() -> (lastByte: UInt8, validBits: UInt8)? {
        guard index != 0 else { return nil }
        defer { clear() }
        return (UInt8(fromBits: bits), index)
    }

    /// - Complexity: O(1).
    @inlinable
    public mutating func flush(into data: inout [UInt8]) {
        guard let wrote:UInt8 = flush()?.lastByte else { return }
        data.append(wrote)
    }

    /// - Complexity: O(1).
    @inlinable
    public mutating func flush(into stream: AsyncStream<UInt8>.Continuation) {
        guard let wrote:UInt8 = flush()?.lastByte else { return }
        stream.yield(wrote)
    }
    
    /// Assigns the `index` to zero and all bits to `false`.
    /// 
    /// - Complexity: O(1).
    @inlinable
    public mutating func clear() {
        index = 0
        bits = (false, false, false, false, false, false, false, false)
    }
}

// MARK: Stream & Data Builder
extension CompressionTechnique {
    public struct StreamBuilder {
        public var stream:AsyncStream<UInt8>.Continuation
        public var builder:ByteBuilder

        public init(stream: AsyncStream<UInt8>.Continuation, builder: ByteBuilder = ByteBuilder()) {
            self.stream = stream
            self.builder = builder
        }

        /// - Complexity: O(1).
        @inlinable
        public mutating func write(bit: Bool) {
            if let wrote:UInt8 = builder.write(bit: bit) {
                stream.yield(wrote)
            }
        }

        /// - Complexity: O(1).
        @inlinable
        public mutating func finalize() {
            builder.flush(into: stream)
        }
    }
    public struct DataBuilder {
        public var data:[UInt8]
        public var builder:ByteBuilder

        public init(data: [UInt8] = [], builder: ByteBuilder = ByteBuilder()) {
            self.data = data
            self.builder = builder
        }

        @inlinable
        public mutating func write(bit: Bool) {
            if let wrote:UInt8 = builder.write(bit: bit) {
                data.append(wrote)
            }
        }
        public mutating func write(bits: [Bool]) {
            builder.write(bits: bits, closure: { data.append($0) })
        }
        public mutating func finalize() {
            builder.flush(into: &data)
        }
    }
}