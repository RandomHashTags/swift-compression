
#if ZlibGzipCompress

import SwiftCompressionUtilities
import ZlibShim

extension Gzip: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]?

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
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

// MARK: Configuration
extension Gzip {
    public struct CompressConfiguration: CompressionConfiguration {
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