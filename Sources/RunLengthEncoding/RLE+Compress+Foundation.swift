
#if RunLengthEncodingCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data
import SwiftCompressionUtilities

extension RunLengthEncoding {
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return compress(data.span, configuration: configuration)
    }
}

#endif