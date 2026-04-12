
#if ZlibDeflateCompress

import SwiftCompressionUtilities
import ZlibShim

extension Deflate: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]?

    public func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        var stream = z_stream()
        let status = deflateInit_(&stream, level, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return span.withUnsafeBufferPointer {
            return compress(baseAddress: $0.baseAddress, count: $0.count, configuration: configuration, stream: &stream)
        }
    }

    package func compress(
        baseAddress: UnsafePointer<UInt8>?,
        count: Int,
        configuration: ConcreteCompressionConfiguration,
        stream: inout z_stream
    ) -> ConcreteCompressionResult {
        defer { deflateEnd(&stream) }

        var compressed = [UInt8]()
        compressed.reserveCapacity(configuration.reserveCapacity)
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        stream.next_in = UnsafeMutablePointer(mutating: baseAddress)
        stream.avail_in = UInt32(count)
        buffer.withUnsafeMutableBufferPointer { b in
            while stream.avail_out == 0 {
                stream.next_out = b.baseAddress
                stream.avail_out = UInt32(bufferSize)
                deflate(&stream, Z_FINISH)

                let count = bufferSize - Int(stream.avail_out)
                compressed.append(contentsOf: b[0..<count])
            }
        }
        return compressed
    }
}

// MARK: Configuration
extension Deflate {
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