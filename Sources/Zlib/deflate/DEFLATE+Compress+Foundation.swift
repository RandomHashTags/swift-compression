
#if ZlibDeflateCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Deflate {
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.1, *)
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        return compress(data.span)
    }
}

#endif