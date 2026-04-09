
import SwiftCompressionUtilities

extension RunLengthEncoding {
    public func compress(
        span: Span<UInt8>,
        configuration: CompressConfiguration
    ) throws(Never) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        span.withUnsafeBufferPointer {
            compress(buffer: $0, closure: compressClosure(closure: { result.append($0) }))
        }
        return result
    }
}