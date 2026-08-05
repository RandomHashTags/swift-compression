
/// Additional values necessary to compress data.
public protocol CompressionConfiguration: Sendable, ~Copyable {
    /// The default compression configuration for a compressor.
    static var `default`: Self { get }
}