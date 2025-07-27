
// MARK: AnyCompressor
public protocol AnyCompressor: Sendable {
    /// Compression algorithm this compressor uses.
    var algorithm: CompressionAlgorithm { get }

    /// Quality of the compressed data.
    var quality: CompressionQuality { get }
}