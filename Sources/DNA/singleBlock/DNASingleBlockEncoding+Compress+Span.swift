
import SwiftCompressionUtilities

extension DNASingleBlockEncoding {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> CompressionResult {
        return span.withUnsafeBufferPointer { compress(buffer: $0, configuration: configuration) }
    }
}