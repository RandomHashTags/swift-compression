
#if ZlibGzipCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Gzip {
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration = .default
    ) -> ConcreteCompressionResult {
        return compress(data.span)
    }
}

#endif