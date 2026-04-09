
extension IWA { // TODO: finish
    public typealias ConcreteCompressionConfiguration = Configuration
    public typealias ConcreteCompressionResult = [UInt8]

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return .init()
    }

    public func compress(
        span: Span<UInt8>,
        configuration: Configuration
    ) throws(Never) -> [UInt8] {
        return .init()
    }
}