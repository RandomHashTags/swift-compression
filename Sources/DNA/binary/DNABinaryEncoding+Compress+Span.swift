
import SwiftCompressionUtilities

extension DNABinaryEncoding {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> CompressionResult {
        var result = CompressionResult()
        let validBitsInLastByte = span.withUnsafeBufferPointer {
            compress(buffer: $0, closure: { result.append($0) })
        }
        return result
    }
}