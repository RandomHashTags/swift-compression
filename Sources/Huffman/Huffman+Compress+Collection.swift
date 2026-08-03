
#if HuffmanCompressCollection

extension Huffman {
    /// Compress a collection of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - collection: Collection of bytes to compress.
    public func compress(
        _ collection: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return collection.withContiguousStorageIfAvailable {
            compress($0.span, configuration: configuration)
        } ?? nil
    }
}

#endif