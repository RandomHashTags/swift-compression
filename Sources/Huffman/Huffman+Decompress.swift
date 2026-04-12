
#if HuffmanDecompress

import ByteBuilder
import SwiftCompressionUtilities

extension Huffman: Decompressor {
    public typealias ConcreteDecompressionConfiguration = DecompressConfiguration

    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> ConcreteDecompressionResult {
        var result = [UInt8]()
        decompress(data: data, root: configuration.root) { result.append($0) }
        return result
    }

    /// Decompress a sequence of bytes into a stream using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func decompress(
        data: [UInt8],
        root: Node?,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        decompress(data: data, root: root) { continuation.yield($0) }
    }

    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    func decompress(
        data: some Collection<UInt8>,
        root: Node?,
        closure: (UInt8) -> Void
    ) {
        let countMinusOne = data.count-1
        var node = root
        var index = 1
        while index < countMinusOne {
            let bits = data[index].bits
            for bit in 0..<8 {
                if bits[bit] {
                    node = node?.right
                } else {
                    node = node?.left
                }
                if let char = node?.character {
                    closure(char)
                    node = root
                }
            }
            index += 1
        }
        let validBitsInLastByte = data[0]
        let lastBits = data[countMinusOne].bits
        for bit in 0..<validBitsInLastByte {
            if lastBits[Int(bit)] {
                node = node?.right
            } else {
                node = node?.left
            }
            if let char = node?.character {
                closure(char)
                node = root
            }
        }
    }
}

extension Huffman {
    /// Decompress a sequence of bytes into a stream using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - frequencyTable: A Huffman frequency table of characters.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    // /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the length of `frequencyTable`. // TODO: FIX
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func decompress(
        data: [UInt8],
        frequencyTable: [Int],
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        guard let root = buildTree(frequencies: frequencyTable) else { return }
        decompress(data: data, root: root, continuation: continuation)
    }
    
    public func decompress(
        data: [UInt8],
        frequencyTable: [Int],
        closure: (UInt8) -> Void
    ) {
        guard let root = buildTree(frequencies: frequencyTable) else { return }
        decompress(data: data, root: root, closure: closure)
    }

    public func decompress(
        data: [UInt8],
        codes: [[Bool]:UInt8],
        closure: (UInt8) -> Void
    ) {
        var code = [Bool]()
        code.reserveCapacity(3)
        for bit in data {
            code.append(bit == 1)
            if let char = codes[code] {
                closure(char)
                code.removeAll(keepingCapacity: true)
            }
        }
    }
}

// MARK: Configuration
extension Huffman {
    public struct DecompressConfiguration: DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public let root:Node?

        public init(
            root: Node? = nil
        ) {
            self.root = root
        }
    }
}

#endif