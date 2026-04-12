
#if SnappyCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Snappy {
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return compress(data.span, configuration: configuration)
    }
}

#endif