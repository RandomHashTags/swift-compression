
/// A type-erased `Compressor` value.
public protocol AnyCompressor: Sendable, ~Copyable {
    /// Compression algorithm this compressor uses.
    var algorithm: CompressionAlgorithm { get }

    /// Quality of the compressed data.
    var compressionQuality: CompressionQuality { get }
}