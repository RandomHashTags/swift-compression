
import SnappyShim
import SwiftCompressionUtilities

extension Snappy {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        let inputSize = span.count
        var outputSize = snappy_max_compressed_length(inputSize)
        return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: outputSize, { buffer in
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
        })
    }
}