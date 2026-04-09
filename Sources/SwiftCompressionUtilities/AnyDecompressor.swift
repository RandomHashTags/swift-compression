
// MARK: AnyDecompressor
public protocol AnyDecompressor: Sendable, ~Copyable {
    /// Decompression algorithm this decompressor uses.
    var algorithm: CompressionAlgorithm { get }

    /// Quality of the decompressed data.
    var compressionQuality: CompressionQuality { get }
}