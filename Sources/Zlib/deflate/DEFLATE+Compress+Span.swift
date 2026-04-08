
import ZlibShim

extension Deflate {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> CompressionResult {
        var stream = z_stream()
        let status = deflateInit_(&stream, level, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return span.withUnsafeBufferPointer {
            return compress(baseAddress: $0.baseAddress, count: $0.count, configuration: configuration, stream: &stream)
        }
    }
}