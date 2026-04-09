
import BrotliShim
import SwiftCompressionUtilities

extension Brotli: Decompressor {
    public typealias ConcreteDecompressionConfiguration = DecompressConfiguration
    public typealias ConcreteDecompressionResult = [UInt8]?

    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> ConcreteDecompressionResult {
        let compressedCount = data.count
        var decodedSize = configuration.estimatedSize
        let outBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: decodedSize)
        outBuffer.initialize(repeating: 0)
        defer { outBuffer.deallocate() }
        let result = data.withContiguousStorageIfAvailable { inPtr in
            BrotliDecoderDecompress(
                compressedCount,
                inPtr.baseAddress!,
                &decodedSize,
                outBuffer.baseAddress
            )
        } ?? BROTLI_DECODER_RESULT_ERROR
        if result == BROTLI_DECODER_RESULT_SUCCESS {
            return [UInt8](outBuffer.prefix(decodedSize))
        } else if result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT {
            return decompress(data: data, configuration: .init(estimatedSize: configuration.estimatedSize * 2))
        }
        return nil
    }
}

// MARK: Configuration
extension Brotli {
    public struct DecompressConfiguration: DecompressionConfiguration {
        public static var `default`: Self { .init(estimatedSize: 32768) }

        public let estimatedSize:Int

        public init(
            estimatedSize: Int
        ) {
            self.estimatedSize = estimatedSize
        }
    }
}