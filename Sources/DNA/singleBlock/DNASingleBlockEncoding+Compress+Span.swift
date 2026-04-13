
import SwiftCompressionUtilities

extension DNASingleBlockEncoding {
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        return span.withUnsafeBufferPointer { compress(buffer: $0, configuration: configuration) }
    }
}