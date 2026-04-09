
public struct BytesBuilder {
    public var data:[UInt8]
    public var builder:ByteBuilder

    public init(data: [UInt8] = [], builder: ByteBuilder = ByteBuilder()) {
        self.data = data
        self.builder = builder
    }

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