
// MARK: Compressor
public protocol Compressor: AnyCompressor, ~Copyable {
    associatedtype ConcreteCompressionConfiguration:CompressionConfiguration
    associatedtype CompressionResult
    associatedtype ConcreteCompressionError:Error = CompressionError

    func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> CompressionResult

    func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> CompressionResult
}