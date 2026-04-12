
#if RunLengthEncodingCompressCollection

import SwiftCompressionUtilities

extension RunLengthEncoding {
    public func compress(
        _ collection: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        collection.withContiguousStorageIfAvailable {
            compress(buffer: $0, closure: compressClosure(closure: { result.append($0) }))
        }
        return result
    }
}

#endif