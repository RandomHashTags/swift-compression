
#if HuffmanCompressFoundation && canImport(FoundationEssentials)

import struct FoundationEssentials.Data

extension Huffman {
    /// Compress `Data` using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: `FoundationEssentials.Data`.
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.1, *)
    public func compress(
        _ data: Data,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return compress(data.span, configuration: configuration)
    }
}

#endif