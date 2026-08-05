
/// Any type conforming to this protocol indicates it decompresses data.
public protocol Decompressor: AnyDecompressor, ~Copyable {
    associatedtype ConcreteDecompressionConfiguration:DecompressionConfiguration
    associatedtype ConcreteDecompressionResult = [UInt8]

    /// Decompress a collection of bytes using this algorithm.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - configuration: Additional values necessary to decompress the data.
    /// 
    /// - Returns: `ConcreteDecompressionResult`; usually, but not guaranteed, an array of bytes (`[UInt8]`).
    func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) throws(DecompressionError) -> ConcreteDecompressionResult
}