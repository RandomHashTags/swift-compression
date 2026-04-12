
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
        return collection.withContiguousStorageIfAvailable { buffer in
            return compress(buffer: buffer, closure: ({ frequencies, codes, root in
                var compressed:[UInt8] = [8]
                var vBitsInLastByte:UInt8 = 8
                if let (lastByte, validBitsInLastByte) = translate(buffer: buffer, codes: codes, closure: { compressed.append($0) }) {
                    compressed[0] = validBitsInLastByte
                    compressed.append(lastByte)
                    vBitsInLastByte = validBitsInLastByte
                }
                return .init(data: compressed, rootNode: root, frequencyTable: frequencies, validBitsInLastByte: vBitsInLastByte)
            }))
        } ?? nil
    }
}

#endif