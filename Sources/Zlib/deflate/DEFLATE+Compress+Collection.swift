
#if ZlibDeflateCompressCollection

import ZlibShim

extension Deflate {
    public func compress(
        _ data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        var stream = z_stream()
        let status = deflateInit_(&stream, level, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { return nil }
        return data.withContiguousStorageIfAvailable { rawBuffer in
            return compress(baseAddress: rawBuffer.baseAddress, count: data.count, configuration: configuration, stream: &stream)
        } ?? nil
    }
}

#endif