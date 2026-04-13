
#if BrotliCompress

import BrotliShim
import SwiftCompressionUtilities

extension Brotli: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]?

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: CompressConfiguration
    ) -> ConcreteCompressionResult {
        var outLength = span.count
        let maxSize = BrotliEncoderMaxCompressedSize(outLength)
        return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: maxSize, { outBuffer in
            let success = span.withUnsafeBytes {
                return BrotliEncoderCompress(
                    quality,
                    windowSize,
                    BrotliEncoderMode(rawValue: mode),
                    outLength,
                    $0.baseAddress,
                    &outLength,
                    outBuffer.baseAddress
                )
            }
            return success == BROTLI_TRUE ? [UInt8](outBuffer.prefix(outLength)) : nil
        })
    }
}

// MARK: Configuration
extension Brotli {
    public struct CompressConfiguration: CompressionConfiguration, DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}

#endif