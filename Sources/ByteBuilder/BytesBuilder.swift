
public struct BytesBuilder {
    public var data:[UInt8]
    public var builder:ByteBuilder

    public init(data: [UInt8] = [], builder: ByteBuilder = ByteBuilder()) {
        self.data = data
        self.builder = builder
    }

    public mutating func write(bit: Bool) {
        if let wrote = builder.write(bit: bit) {
            data.append(wrote)
        }
    }
    public mutating func write(amount: Int, bits: UInt8) {
        builder.write(amount: amount, bits: bits, closure: { data.append($0) })
    }
    public mutating func write<T: FixedWidthInteger>(amount: Int, bits: T) {
        builder.write(amount: amount, bits: bits, closure: { data.append($0) })
    }
    public mutating func finalize() {
        builder.flush(into: &data)
    }
}