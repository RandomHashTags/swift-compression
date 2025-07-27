
// MARK: AnyDecompressor
public protocol AnyDecompressor: Sendable {
    /// Decompression algorithm this decompressor uses.
    var algorithm: CompressionAlgorithm { get }

    /// Quality of the decompressed data.
    var quality: CompressionQuality { get }
}