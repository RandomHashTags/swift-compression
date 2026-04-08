
import ZlibShim

extension Gzip {
    public func compress(
        span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> CompressionResult {
        var stream = z_stream()
        let windowBits:Int32 = 15 + 16
        let status = deflateInit2_(
            &stream,
            level,
            Z_DEFLATED,
            windowBits,
            memLevel,
            strategy,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )
        guard status == Z_OK else { return nil }
        return span.withUnsafeBufferPointer {
            return Deflate(
                bufferSize: bufferSize,
                level: level
            ).compress(
                baseAddress: $0.baseAddress,
                count: $0.count,
                configuration: .init(reserveCapacity: configuration.reserveCapacity),
                stream: &stream
            )
        } ?? nil
    }
}