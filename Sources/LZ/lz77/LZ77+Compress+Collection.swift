
#if LZ77CompressCollection

import SwiftCompressionUtilities

extension LZ77 {
    // Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        _ collection: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        result.reserveCapacity(configuration.reserveCapacity)
        collection.withContiguousStorageIfAvailable {
            compress(buffer: $0, closure: { result.append($0) })
        }
        return result
    }
}

#endif