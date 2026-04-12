
#if ZlibGzipDecompress

import SwiftCompressionUtilities
import ZlibShim

extension Gzip: Decompressor {
    public typealias ConcreteDecompressionConfiguration = DecompressConfiguration
    public typealias ConcreteDecompressionResult = [UInt8]?

    public func decompress(
        _ span: Span<UInt8>,
        configuration: DecompressConfiguration = .default
    ) -> ConcreteDecompressionResult {
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

// MARK: Configuration
extension Gzip {
    public struct DecompressConfiguration: DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public let reserveCapacity:Int

        public init(
            reserveCapacity: Int = 1024
        ) {
            self.reserveCapacity = reserveCapacity
        }
    }
}

#endif