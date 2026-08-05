
#if ZlibDeflateDecompress

import SwiftCompressionUtilities
import ZlibShim

extension Deflate: Decompressor {
    public typealias ConcreteDecompressionConfiguration = DecompressConfiguration
    public typealias ConcreteDecompressionResult = [UInt8]?

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func decompress(
        span: Span<UInt8>,
        configuration: ConcreteDecompressionConfiguration = .default
    ) -> ConcreteDecompressionResult {
        var stream = z_stream()
        let status = inflateInit_(&stream, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return span.withUnsafeBufferPointer {
            return decompress(baseAddress: $0.baseAddress, count: $0.count, configuration: configuration, stream: &stream) 
        } ?? nil
    }

    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration = .default
    ) -> ConcreteDecompressionResult {
        var stream = z_stream()
        let status = inflateInit_(&stream, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return data.withContiguousStorageIfAvailable {
            return decompress(baseAddress: $0.baseAddress, count: $0.count, configuration: configuration, stream: &stream) 
        } ?? nil
    }

    package func decompress(
        baseAddress: UnsafePointer<UInt8>?,
        count: Int,
        configuration: ConcreteDecompressionConfiguration,
        stream: inout z_stream
    ) -> ConcreteDecompressionResult {
        defer { inflateEnd(&stream) }

        var decompressedData = [UInt8]()
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        stream.next_in = UnsafeMutablePointer(mutating: baseAddress)
        stream.avail_in = UInt32(count)

        buffer.withUnsafeMutableBufferPointer { b in
            while stream.avail_out == 0 {
                stream.next_out = b.baseAddress
                stream.avail_out = UInt32(bufferSize)
                inflate(&stream, Z_NO_FLUSH)

                let count = bufferSize - Int(stream.avail_out)
                decompressedData.append(contentsOf: b[0..<count])
            }
        }
        return decompressedData
    }
}

// MARK: Configuration
extension Deflate {
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