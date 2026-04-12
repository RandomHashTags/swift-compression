
#if ZlibGzipCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Gzip {
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        return compress(data.span)
    }
}

#endif