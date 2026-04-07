
import SwiftCompressionUtilities
import ZlibShim

extension Gzip: Compressor {
    public typealias CompressionConfiguration = CompressConfiguration
    public typealias CompressionResult = [UInt8]?

    public func compress(
        data: some Collection<UInt8>,
        configuration: CompressionConfiguration = .init()
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
        return Deflate(
            bufferSize: bufferSize,
            level: level
        ).compress(
            data: data,
            configuration: .init(reserveCapacity: configuration.reserveCapacity),
            stream: &stream
        )
    }
}

// MARK: Configuration
extension Gzip {
    public struct CompressConfiguration: Sendable {
        public let reserveCapacity:Int

        public init(reserveCapacity: Int = 1024) {
            self.reserveCapacity = reserveCapacity
        }
    }
}