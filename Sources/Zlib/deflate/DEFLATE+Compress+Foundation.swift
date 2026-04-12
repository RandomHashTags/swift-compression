
#if ZlibDeflateCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Deflate {
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        return compress(data.span)
    }
}

#endif