
public protocol Compressor: AnyCompressor, ~Copyable {
    associatedtype ConcreteCompressionConfiguration:CompressionConfiguration
    associatedtype ConcreteCompressionResult = [UInt8]
    associatedtype ConcreteCompressionError:Error = CompressionError

    func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult

    func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult
}