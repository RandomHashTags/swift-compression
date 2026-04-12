
#if LZ77CompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension LZ77 {
    /// Compress `Data` using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: `FoundationEssentials.Data`.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return compress(data.span, configuration: configuration)
    }
}

#endif