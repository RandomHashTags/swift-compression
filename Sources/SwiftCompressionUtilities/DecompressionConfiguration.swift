
/// Additional values necessary to decompress data.
public protocol DecompressionConfiguration: Sendable, ~Copyable {
    /// The default decompression configuration for a decompressor.
    static var `default`: Self { get }
}