
#if SnappyCompress

import SnappyShim
import SwiftCompressionUtilities

extension Snappy: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]?

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        let inputSize = span.count
        var outputSize = snappy_max_compressed_length(inputSize)
        return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: outputSize, { buffer in
            let result = span.withUnsafeBufferPointer {
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
    public struct CompressConfiguration: CompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}

#endif