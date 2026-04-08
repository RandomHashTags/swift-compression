
import SwiftCompressionUtilities

extension RunLengthEncoding {
    public func compress(
        span: Span<UInt8>,
        configuration: CompressConfiguration
    ) throws(Never) -> CompressionResult {
        var result = CompressionResult()
        span.withUnsafeBufferPointer {
            compress(buffer: $0, closure: compressClosure(closure: { result.append($0) }))
        }
        return result
    }
}