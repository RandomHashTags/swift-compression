
import SwiftCompressionUtilities

extension DNABinaryEncoding {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        let validBitsInLastByte = span.withUnsafeBufferPointer {
            compress(buffer: $0, closure: { result.append($0) })
        }
        return result
    }
}