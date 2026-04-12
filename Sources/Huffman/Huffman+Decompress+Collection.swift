
#if HuffmanDecompressCollection

import SwiftCompressionUtilities

extension Huffman {
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - frequencyTable: A Huffman frequency table of characters.
    // /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the length of `frequencyTable`. // TODO: FIX
    public func decompress(
        _ collection: some Collection<UInt8>,
        frequencyTable: [Int]
    ) -> [UInt8] {
        guard let root = buildTree(frequencies: frequencyTable) else { return [UInt8](collection) }
        return decompress(data: collection, configuration: .init(root: root))
    }
}

#endif