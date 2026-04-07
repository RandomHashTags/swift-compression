
// MARK: Decompressor
public protocol Decompressor: AnyDecompressor, ~Copyable {
    associatedtype DecompressionConfiguration
    associatedtype DecompressionResult

    /// Decompress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    func decompress(
        data: some Collection<UInt8>,
        configuration: DecompressionConfiguration
    ) throws(DecompressionError) -> DecompressionResult
}