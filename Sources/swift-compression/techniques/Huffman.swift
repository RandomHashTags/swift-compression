//
//  Huffman.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

#if canImport(Foundation)
import Foundation
#endif

public extension CompressionTechnique {
    /// The Huffman coding compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Huffman_coding
    enum Huffman {
    }
}

// MARK: Compress
public extension CompressionTechnique.Huffman {
    /// Compress a sequence of bytes using the Huffman Coding technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    @inlinable
    static func compress<S: Sequence<UInt8>>(data: S) -> CompressionResult<[UInt8]>? {
        return compress(data: data) { frequencies, codes, root in
            var compressed:[UInt8] = [8]
            var vBitsInLastByte:UInt8 = 8
            if let (lastByte, validBitsInLastByte):(UInt8, UInt8) = translate(data: data, codes: codes, closure: { compressed.append($0) }) {
                compressed[0] = validBitsInLastByte
                compressed.append(lastByte)
                vBitsInLastByte = validBitsInLastByte
            }
            return CompressionResult(data: compressed, rootNode: root, frequencyTable: frequencies, validBitsInLastByte: vBitsInLastByte)
        }
    }

    /// Compress a sequence of bytes to a stream using the Huffman Coding technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> CompressionResult<AsyncStream<UInt8>>? {
        // TODO: fix
        return compress(data: data) { frequencies, codes, root in
            var vBitsInLastByte:UInt8 = 8
            let stream:AsyncStream<UInt8> = AsyncStream(bufferingPolicy: limit) { continuation in
                if let (lastByte, validBitsInLastByte):(UInt8, UInt8) = translate(data: data, codes: codes, closure: { continuation.yield($0) }) {
                    continuation.yield(lastByte)
                    vBitsInLastByte = validBitsInLastByte
                }
                continuation.finish()
            }
            return CompressionResult(data: stream, rootNode: root, frequencyTable: frequencies, validBitsInLastByte: vBitsInLastByte)
        }
    }

    @inlinable
    static func compress<T, S: Sequence<UInt8>>(data: S, closure: ([Int], [UInt8:String], Node) -> T) -> T? {
        var frequencies:[Int] = Array(repeating: 0, count: Int(UInt8.max-1))
        for byte in data {
            frequencies[Int(byte)] += 1
        }
        guard let root:Node = buildTree(frequencies: frequencies) else { return nil }
        var codes:[UInt8:String] = [:]
        generateCodes(node: root, codes: &codes)
        return closure(frequencies, codes, root)
    }

    @inlinable
    static func translate<T: Sequence<UInt8>>(data: T, codes: [UInt8:String], closure: (UInt8) -> Void) -> (lastByte: UInt8, bitsFilled: UInt8)? {
        var builder:CompressionTechnique.IntBitBuilder = .init()
        for byte in data {
            if let tree:String = codes[byte] {
                for char in tree {
                    if let wrote:UInt8 = builder.write(bit: char == "1") {
                        closure(wrote)
                    }
                }
            }
        }
        return builder.flush()
    }
}

// MARK: Decompress
public extension CompressionTechnique.Huffman {
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    @inlinable
    static func decompress(data: [UInt8], root: Node?) -> [UInt8] {
        var result:[UInt8] = []
        decompress(data: data, root: root) { result.append($0) }
        return result
    }

    /// Decompress a sequence of bytes into a stream using the Huffman Coding technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    @inlinable
    static func decompress(
        data: [UInt8],
        root: Node?,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            decompress(data: data, root: root) { continuation.yield($0) }
            continuation.finish()
        }
    }

    @inlinable
    static func decompress(data: [UInt8], root: Node?, closure: (UInt8) -> Void) {
        let countMinusOne:Int = data.count-1
        var node:Node? = root
        var index:Int = 1
        while index < countMinusOne {
            let bits:[Bool] = data[index].bits
            for bit in 0..<8 {
                if bits[bit] {
                    node = node?.right
                } else {
                    node = node?.left
                }
                if let char:UInt8 = node?.character {
                    closure(char)
                    node = root
                }
            }
            index += 1
        }
        let validBitsInLastByte:UInt8 = data[0]
        let lastBits:[Bool] = data[countMinusOne].bits
        for bit in 0..<validBitsInLastByte {
            if lastBits[Int(bit)] {
                node = node?.right
            } else {
                node = node?.left
            }
            if let char:UInt8 = node?.character {
                closure(char)
                node = root
            }
        }
    }
}

public extension CompressionTechnique.Huffman {
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - frequencyType: A Huffman frequency table of characters.
    @inlinable
    static func decompress(data: [UInt8], frequencyTable: [Int]) -> [UInt8] {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return data }
        return decompress(data: data, root: root)
    }

    /// Decompress a sequence of bytes into a stream using the Huffman Coding technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - frequencyType: A Huffman frequency table of characters.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    @inlinable
    static func decompress(
        data: [UInt8],
        frequencyTable: [Int],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return AsyncStream(bufferingPolicy: limit) { $0.finish() } }
        return decompress(data: data, root: root, bufferingPolicy: limit)
    }
    
    @inlinable
    static func decompress(data: [UInt8], frequencyTable: [Int], closure: (UInt8) -> Void) {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return }
        decompress(data: data, root: root, closure: closure)
    }

    @inlinable
    static func decompress(data: [UInt8], codes: [[Bool]:UInt8], closure: (UInt8) -> Void) {
        var code:[Bool] = []
        code.reserveCapacity(3)
        for bit in data {
            code.append(bit == 1)
            if let char:UInt8 = codes[code] {
                closure(char)
                code.removeAll(keepingCapacity: true)
            }
        }
    }
}

// MARK: Node
public extension CompressionTechnique.Huffman {
    /// A Huffman Node.
    final class Node : Comparable {
        public static func < (left: Node, right: Node) -> Bool {
            return left.frequency < right.frequency
        }
        public static func == (left: Node, right: Node) -> Bool {
            return left.frequency == right.frequency
        }

        public var character:UInt8?
        public var frequency:Int
        public var left:Node?
        public var right:Node?

        public init(
            character: UInt8? = nil,
            frequency: Int,
            left: Node? = nil,
            right: Node? = nil
        ) {
            self.character = character
            self.frequency = frequency
            self.left = left
            self.right = right
        }
    }
}

// MARK: PriorityQueue
public extension CompressionTechnique.Huffman {
    struct PriorityQueue<T: Comparable> {
        public var heap:[T]

        public init(heap: [T] = []) {
            self.heap = heap
        }

        @inlinable
        mutating func push(_ element: T) {
            heap.append(element)
            siftUp(from: heap.count - 1)
        }

        @inlinable
        mutating func pop() -> T? {
            guard !heap.isEmpty else { return nil }
            if heap.count == 1 {
                return heap.removeLast()
            }
            let root:T = heap[0]
            heap[0] = heap.removeLast()
            siftDown(from: 0)
            return root
        }

        @inlinable
        mutating func siftUp(from index: Int) {
            var index:Int = index
            while index > 0 {
                let parentIndex:Int = (index - 1) / 2
                if heap[index] >= heap[parentIndex] { break }
                heap.swapAt(index, parentIndex)
                index = parentIndex
            }
        }

        @inlinable
        mutating func siftDown(from index: Int) {
            let element:T = heap[index], count:Int = heap.count
            var index:Int = index
            while true {
                let leftIndex:Int = (2 * index) + 1
                let rightIndex:Int = leftIndex + 1
                var minIndex:Int = index
                
                if leftIndex < count && heap[leftIndex] < heap[minIndex] {
                    minIndex = leftIndex
                }
                if rightIndex < count && heap[rightIndex] < heap[minIndex] {
                    minIndex = rightIndex
                }
                if minIndex == index { break }
                
                heap[index] = heap[minIndex]
                index = minIndex
            }
            heap[index] = element
        }
    }
}

// MARK: Logic
extension CompressionTechnique.Huffman {
    /// - Returns: The root node of the Huffman tree.
    @inlinable
    static func buildTree(frequencies: [Int]) -> Node? {
        var queue:PriorityQueue<Node> = .init()
        for (char, freq) in frequencies.enumerated() {
            if freq != 0 {
                queue.push(Node(character: UInt8(char), frequency: freq))
            }
        }
        while queue.heap.count > 1 {
            let left:Node = queue.pop()!, right:Node = queue.pop()!
            let merged:Node = Node(frequency: left.frequency + right.frequency, left: left, right: right)
            queue.push(merged)
        }
        return queue.pop()
    }

    /// Generates the binary codes for a node.
    @inlinable
    static func generateCodes(node: Node?, code: String = "", codes: inout [UInt8:String]) {
        guard let node:Node = node else { return }
        if let char:UInt8 = node.character {
            codes[char] = code
        } else {
            generateCodes(node: node.left, code: code + "0", codes: &codes)
            generateCodes(node: node.right, code: code + "1", codes: &codes)
        }
    }
}

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compresses this data using the Huffman coding technique.
    /// - Returns: `self`.
    @discardableResult
    @inlinable
    mutating func decompressHuffmanCoding(root: CompressionTechnique.Huffman.Node?) -> Self {
        self = CompressionTechnique.Huffman.decompress(data: self, root: root)
        return self
    }

    /// Compress a copy of this data using the Huffman coding technique.
    /// - Returns: The compressed data.
    @inlinable
    func decompressedHuffmanCoding(root: CompressionTechnique.Huffman.Node?) -> [UInt8] {
        return CompressionTechnique.Huffman.decompress(data: self, root: root)
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Compress this data to a stream using the Huffman coding technique.
    /// - Parameters:
    ///   - root: The root Huffman coding node.
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that decompresses the data.
    @inlinable
    func decompressHuffmanCoding(
        root: CompressionTechnique.Huffman.Node?,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.Huffman.decompress(data: self, root: root, bufferingPolicy: limit)
    }
}

#if canImport(Foundation)
public extension Data {
    /// Compress this data into a stream using the Run-length encoding technique.
    /// - Parameters:
    ///   - root: The root Huffman coding node.
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that compresses the data.
    @inlinable
    func decompressHuffmanCoding(
        root: CompressionTechnique.Huffman.Node?,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.Huffman.decompress(data: [UInt8](self), root: root, bufferingPolicy: limit)
    }
}
#endif

// MARK: StringProtocol
public extension StringProtocol {
    /// - Returns: A Huffman frequency table for the characters.
    @inlinable
    func huffmanFrequencyTable() -> [Int] {
        var table:[Int] = Array(repeating: 0, count: 255)
        for char in self {
            for byte in char.utf8 {
                table[Int(byte)] += 1
            }
        }
        return table
    }
}