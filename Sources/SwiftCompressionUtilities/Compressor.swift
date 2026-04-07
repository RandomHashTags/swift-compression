
// MARK: Compressor
public protocol Compressor: AnyCompressor, ~Copyable {
    associatedtype CompressionConfiguration
    associatedtype CompressionResult
    associatedtype CompressionErrorType:Error = CompressionError

    func compress(
        data: some Collection<UInt8>,
        configuration: CompressionConfiguration
    ) throws(CompressionErrorType) -> CompressionResult
}