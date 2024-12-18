//
//  Huffman.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

#if canImport(Foundation)
import Foundation
#endif

// https://en.wikipedia.org/wiki/Huffman_coding
public extension CompressionTechnique {
    enum Huffman {
    }
}

// MARK: Compress
public extension CompressionTechnique.Huffman {
    @inlinable
    static func compress(data: [UInt8]) -> CompressionResult<[UInt8]> {
        return compress(data: data) { frequencies, codes, root in
            var compressed:[UInt8] = []
            translate(data: data, codes: codes, closure: { compressed.append($0) })
            return CompressionResult(data: compressed, rootNode: root, frequencyTable: frequencies)
        } ?? CompressionResult(data: data)
    }

    @inlinable
    static func compress(data: [UInt8], bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded) -> CompressionResult<AsyncStream<UInt8>> {
        return compress(data: data) { frequencies, codes, root in
            return CompressionResult(
                data: AsyncStream(bufferingPolicy: limit) { continuation in
                    translate(data: data, codes: codes, closure: { continuation.yield($0) })
                    continuation.finish()
                },
                rootNode: root, frequencyTable: frequencies)
        } ?? CompressionResult(data: AsyncStream(bufferingPolicy: limit) { $0.finish() })
    }

    @inlinable
    static func compress<T>(data: [UInt8], closure: ([Int], [UInt8:String], Node) -> T) -> T? {
        var frequencies:[Int] = Array(repeating: 0, count: Int(UInt8.max-1))
        for byte in data {
            frequencies[Int(byte)] += 1
        }
        guard let root:Node = buildTree(frequencies: frequencies) else { return nil }
        var codes:[UInt8:String] = [:]
        generateCodes(root: root, codes: &codes)
        return closure(frequencies, codes, root)
    }

    @inlinable
    static func translate(data: [UInt8], codes: [UInt8:String], closure: (UInt8) -> Void) {
        for byte in data {
            if let tree:String = codes[byte] {
                for char in tree {
                    closure(char == "1" ? 1 : 0)
                }
            }
        }
    }
}

// MARK: Decompress
public extension CompressionTechnique.Huffman {
    @inlinable
    static func decompress(data: [UInt8], root: Node?) -> [UInt8] {
        var result:[UInt8] = []
        decompress(data: data, root: root) { result.append($0) }
        return result
    }

    @inlinable
    static func decompress(data: [UInt8], root: Node?, bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            decompress(data: data, root: root) { continuation.yield($0) }
            continuation.finish()
        }
    }

    @inlinable
    static func decompress(data: [UInt8], root: Node?, closure: (UInt8) -> Void) {
        var node:Node? = root
        for bit in data {
            if bit == 0 {
                node = node?.left
            } else {
                node = node?.right
            }
            if let char:UInt8 = node?.character {
                closure(char)
                node = root
            }
        }
    }
}

public extension CompressionTechnique.Huffman {
    @inlinable
    static func decompress(data: [UInt8], frequencyTable: [Int]) -> [UInt8] {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return data }
        return decompress(data: data, root: root)
    }

    @inlinable
    static func decompress(data: [UInt8], frequencyTable: [Int], bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded) -> AsyncStream<UInt8> {
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

    @inlinable
    static func generateCodes(root: Node?, code: String = "", codes: inout [UInt8:String]) {
        guard let root:Node = root else { return }
        if let char:UInt8 = root.character {
            codes[char] = code
        } else {
            generateCodes(root: root.left, code: code + "0", codes: &codes)
            generateCodes(root: root.right, code: code + "1", codes: &codes)
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