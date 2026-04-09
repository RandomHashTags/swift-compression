
import SnappyShim
import SwiftCompressionUtilities

extension Snappy {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        let inputSize = span.count
        var outputSize = snappy_max_compressed_length(inputSize)
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: outputSize)
        buffer.initialize(repeating: 0)
        defer { buffer.deallocate() }
        let result = span.withUnsafeBufferPointer {
            snappy_compress(
                $0.baseAddress,
                inputSize,
                buffer.baseAddress,
                &outputSize
            )
        }
        guard result == SNAPPY_OK else { return nil }
        return [UInt8](buffer.prefix(outputSize))
    }
}