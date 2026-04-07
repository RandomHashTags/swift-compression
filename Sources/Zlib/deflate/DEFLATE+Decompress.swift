
import SwiftCompressionUtilities
import ZlibShim

extension Deflate: Decompressor {
    public typealias DecompressionConfiguration = DecompressConfiguration
    public typealias DecompressionResult = [UInt8]?

    public func decompress(
        data: some Collection<UInt8>,
        configuration: DecompressionConfiguration = .init()
    ) -> DecompressionResult {
        var stream = z_stream()
        let status = inflateInit_(&stream, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return decompress(data: data, configuration: configuration, stream: &stream)
    }

    func decompress(
        data: some Collection<UInt8>,
        configuration: DecompressionConfiguration,
        stream: inout z_stream
    ) -> DecompressionResult {
        defer { inflateEnd(&stream) }

        var decompressedData = [UInt8]()
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        data.withContiguousStorageIfAvailable { rawBuffer in
            stream.next_in = UnsafeMutablePointer(mutating: rawBuffer.baseAddress)
            stream.avail_in = UInt32(data.count)

            buffer.withUnsafeMutableBufferPointer { b in
                while stream.avail_out == 0 {
                    stream.next_out = b.baseAddress
                    stream.avail_out = UInt32(bufferSize)
                    inflate(&stream, Z_NO_FLUSH)

                    let count = bufferSize - Int(stream.avail_out)
                    decompressedData.append(contentsOf: b[0..<count])
                }
            }
        }
        return decompressedData
    }
}

// MARK: Configuration
extension Deflate {
    public struct DecompressConfiguration: Sendable {
        public let reserveCapacity:Int

        public init(
            reserveCapacity: Int = 1024
        ) {
            self.reserveCapacity = reserveCapacity
        }
    }
}