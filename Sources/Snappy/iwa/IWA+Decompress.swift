
extension IWA { // TODO: finish
    public typealias ConcreteDecompressionConfiguration = Configuration
    public typealias DecompressionResult = [UInt8]

    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> DecompressionResult {
        return .init()
    }
}