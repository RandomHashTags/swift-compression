
import ZlibShim

extension Deflate {
    public func decompress(
        span: Span<UInt8>,
        configuration: DecompressionConfiguration = .init()
    ) -> DecompressionResult {
        var stream = z_stream()
        let status = inflateInit_(&stream, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return span.withUnsafeBufferPointer {
            return decompress(baseAddress: $0.baseAddress, count: $0.count, configuration: configuration, stream: &stream) 
        } ?? nil
    }
}