
import SnappyShim
import SwiftCompressionUtilities

extension Snappy: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]?

    public func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        let inputSize = data.count
        var outputSize = snappy_max_compressed_length(inputSize)
        return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: outputSize, { buffer in
            let result = data.withContiguousStorageIfAvailable {
                snappy_compress(
                    $0.baseAddress,
                    inputSize,
                    buffer.baseAddress,
                    &outputSize
                )
            }
            guard result == SNAPPY_OK else { return nil }
            return [UInt8](buffer.prefix(outputSize))
        })
    }
}

// MARK: Configuration
extension Snappy {
    public struct CompressConfiguration: CompressionConfiguration, DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}