
import ZlibShim

extension Gzip {
    public func decompress(
        span: Span<UInt8>,
        configuration: DecompressConfiguration = .init()
    ) -> DecompressionResult {
        var stream = z_stream()
        let windowBits:Int32 = 15 + 16
        let status = inflateInit2_(
            &stream,
            windowBits,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )
        guard status == Z_OK else { return nil }
        return span.withUnsafeBufferPointer {
            return Deflate(
                bufferSize: bufferSize,
                level: level
            ).decompress(
                baseAddress: $0.baseAddress,
                count: $0.count,
                configuration: .init(reserveCapacity: configuration.reserveCapacity),
                stream: &stream
            )
        } ?? nil
    }
}