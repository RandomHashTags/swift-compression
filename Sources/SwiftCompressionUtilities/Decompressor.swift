
// MARK: Decompressor
public protocol Decompressor: AnyDecompressor, ~Copyable {
    associatedtype ConcreteDecompressionConfiguration:DecompressionConfiguration
    associatedtype DecompressionResult

    /// Decompress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) throws(DecompressionError) -> DecompressionResult
}