
import SwiftCompressionUtilities

extension IWA: Compressor { // TODO: finish
    public typealias ConcreteCompressionConfiguration = Configuration

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return .init()
    }

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: Configuration
    ) throws(Never) -> [UInt8] {
        return .init()
    }
}