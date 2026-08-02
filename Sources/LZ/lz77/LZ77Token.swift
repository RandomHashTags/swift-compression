
public struct LZ77Token: Sendable {
    public let offset:Int
    public let length:Int
    public let char:UInt8

    public init(
        offset: Int,
        length: Int,
        char: UInt8
    ) {
        self.offset = offset
        self.length = length
        self.char = char
    }
}