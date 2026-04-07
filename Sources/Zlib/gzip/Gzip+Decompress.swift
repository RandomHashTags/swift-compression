
import SwiftCompressionUtilities
import ZlibShim

extension Gzip: Decompressor {
    public typealias DecompressionConfiguration = DecompressConfiguration
    public typealias DecompressionResult = [UInt8]?

    public func decompress(
        data: some Collection<UInt8>,
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
        return Deflate(
            bufferSize: bufferSize,
            level: level
        ).decompress(
            data: data,
            configuration: .init(reserveCapacity: configuration.reserveCapacity),
            stream: &stream
        )
    }
}

// MARK: Configuration
extension Gzip {
    public struct DecompressConfiguration: Sendable {
        public let reserveCapacity:Int

        public init(
            reserveCapacity: Int = 1024
        ) {
            self.reserveCapacity = reserveCapacity
        }
    }
}