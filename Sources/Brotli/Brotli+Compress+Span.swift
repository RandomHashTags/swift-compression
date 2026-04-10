
import BrotliShim

extension Brotli {
    public func compress(
        span: Span<UInt8>,
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