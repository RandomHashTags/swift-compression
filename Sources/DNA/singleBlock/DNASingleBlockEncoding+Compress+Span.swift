
import SwiftCompressionUtilities

extension DNASingleBlockEncoding {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        return span.withUnsafeBufferPointer { compress(buffer: $0, configuration: configuration) }
    }
}