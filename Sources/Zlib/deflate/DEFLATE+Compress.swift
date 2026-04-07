
import SwiftCompressionUtilities
import ZlibShim

extension Deflate {
    public func compress(
        data: some Collection<UInt8>,
        reserveCapacity: Int = 1024
    ) -> CompressionResult<[UInt8]>? {
        var stream = z_stream()
        let status = deflateInit_(&stream, level, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        defer { deflateEnd(&stream) }

        var compressed = [UInt8]()
        compressed.reserveCapacity(reserveCapacity)
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        data.withContiguousStorageIfAvailable { rawBuffer in
            stream.next_in = UnsafeMutablePointer(mutating: rawBuffer.baseAddress)
            stream.avail_in = UInt32(data.count)
            buffer.withUnsafeMutableBufferPointer { b in
                while stream.avail_out == 0 {
                    stream.next_out = b.baseAddress
                    stream.avail_out = UInt32(bufferSize)
                    deflate(&stream, Z_FINISH)

                    let count = bufferSize - Int(stream.avail_out)
                    compressed.append(contentsOf: b[0..<count])
                }
            }
        }
        return .init(data: compressed)
    }
}