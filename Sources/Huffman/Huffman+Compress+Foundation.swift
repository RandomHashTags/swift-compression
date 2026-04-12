
#if HuffmanCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Huffman {
    /// Compress `Data` using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: `FoundationEssentials.Data`.
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return compress(data.span, configuration: configuration)
    }
}

#endif