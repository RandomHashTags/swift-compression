
import BrotliShim
import SwiftCompressionUtilities

extension Brotli: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]?

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var outLength = data.count
        let maxSize = BrotliEncoderMaxCompressedSize(outLength)
        let outBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: maxSize)
        outBuffer.initialize(repeating: 0)
        defer { outBuffer.deallocate() }

        let success = data.withContiguousStorageIfAvailable {
            return BrotliEncoderCompress(
                quality,
                windowSize,
                BrotliEncoderMode(rawValue: mode),
                outLength,
                $0.baseAddress,
                &outLength,
                outBuffer.baseAddress
            )
        } ?? BROTLI_FALSE
        return success == BROTLI_TRUE ? [UInt8](outBuffer.prefix(outLength)) : nil
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