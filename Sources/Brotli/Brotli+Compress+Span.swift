
import BrotliShim

extension Brotli {
    public func compress(
        span: Span<UInt8>,
        configuration: CompressConfiguration
    ) -> ConcreteCompressionResult {
        var outLength = span.count
        let maxSize = BrotliEncoderMaxCompressedSize(outLength)
        let outBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: maxSize)
        outBuffer.initialize(repeating: 0)
        defer { outBuffer.deallocate() }

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
    }
}