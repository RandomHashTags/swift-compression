
extension IWA { // TODO: finish
    public typealias CompressionConfiguration = Configuration
    public typealias CompressionResult = [UInt8]

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        data: some Collection<UInt8>,
        configuration: CompressionConfiguration
    ) -> CompressionResult {
        return .init()
    }
}