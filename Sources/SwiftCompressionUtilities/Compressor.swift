
/// Any type conforming to this protocol indicates it compresses data.
public protocol Compressor: AnyCompressor, ~Copyable {
    associatedtype ConcreteCompressionConfiguration:CompressionConfiguration
    associatedtype ConcreteCompressionResult = [UInt8]
    associatedtype ConcreteCompressionError:Error = CompressionError

    /// Compresses a collection of bytes.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - configuration: Additional values necessary to compress the provided data.
    /// 
    /// - Returns: `ConcreteCompressionResult`; usually, but not guaranteed, an array of bytes (`[UInt8]`).
    func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult

    /// Compresses a span of bytes.
    /// 
    /// - Parameters:
    ///   - data: The span of bytes to compress.
    ///   - configuration: Additional values necessary to compress the provided data.
    /// 
    /// - Returns: `ConcreteCompressionResult`; usually, but not guaranteed, an array of bytes (`[UInt8]`).
    func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult
}