
import SwiftCompressionUtilities

extension DNASingleBlockEncoding: Decompressor { // TODO: finish
    public typealias ConcreteDecompressionConfiguration = DecompressConfiguration
    public typealias DecompressionResult = [UInt8]

    /// Decompress a sequence of bytes using the DNA single block encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> DecompressionResult {
        return []
    }
}

// MARK: Configuration
extension DNASingleBlockEncoding {
    public struct DecompressConfiguration: DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}