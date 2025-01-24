//
//  Huffman.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

extension CompressionTechnique {
    /// The Huffman coding compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Huffman_coding
    public enum Huffman {
    }
}

// MARK: Compress
extension CompressionTechnique.Huffman {
    /// Compress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    @inlinable
    public static func compress<S: Sequence<UInt8>>(data: S) -> CompressionResult<[UInt8]>? {
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
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    @inlinable
    public static func compress<S: Sequence<UInt8>>(
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
    public static func compress<T, S: Sequence<UInt8>>(data: S, closure: ([Int], [UInt8:String], Node) -> T) -> T? {
        var frequencies:[Int] = Array(repeating: 0, count: Int(UInt8.max-1))
        for byte in data {
            frequencies[Int(byte)] += 1
        }
        guard let root:Node = buildTree(frequencies: frequencies) else { return nil }
        var codes:[UInt8:String] = [:]
        generateCodes(node: root, codes: &codes)
        return closure(frequencies, codes, root)
    }

    /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the sum of the code lengths.
    @inlinable
    public static func translate<T: Sequence<UInt8>>(data: T, codes: [UInt8:String], closure: (UInt8) -> Void) -> (lastByte: UInt8, validBits: UInt8)? {
        var builder:ByteBuilder = .init()
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
extension CompressionTechnique.Huffman {
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public static func decompress(data: [UInt8], root: Node?) -> [UInt8] {
        var result:[UInt8] = []
        decompress(data: data, root: root) { result.append($0) }
        return result
    }

    /// Decompress a sequence of bytes into a stream using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public static func decompress(
        data: [UInt8],
        root: Node?,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        decompress(data: data, root: root) { continuation.yield($0) }
    }

    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public static func decompress(data: [UInt8], root: Node?, closure: (UInt8) -> Void) {
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

extension CompressionTechnique.Huffman {
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - frequencyTable: A Huffman frequency table of characters.
    // /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the length of `frequencyTable`. // TODO: FIX
    @inlinable
    public static func decompress(data: [UInt8], frequencyTable: [Int]) -> [UInt8] {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return data }
        return decompress(data: data, root: root)
    }

    /// Decompress a sequence of bytes into a stream using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - frequencyTable: A Huffman frequency table of characters.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    // /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the length of `frequencyTable`. // TODO: FIX
    @inlinable
    public static func decompress(
        data: [UInt8],
        frequencyTable: [Int],
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return }
        decompress(data: data, root: root, continuation: continuation)
    }
    
    @inlinable
    public static func decompress(data: [UInt8], frequencyTable: [Int], closure: (UInt8) -> Void) {
        guard let root:Node = buildTree(frequencies: frequencyTable) else { return }
        decompress(data: data, root: root, closure: closure)
    }

    @inlinable
    public static func decompress(data: [UInt8], codes: [[Bool]:UInt8], closure: (UInt8) -> Void) {
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
extension CompressionTechnique.Huffman {
    /// A Huffman Node.
    public final class Node : Comparable, Hashable, Sendable {
        public static func < (left: Node, right: Node) -> Bool {
            return left.frequency < right.frequency
        }
        public static func == (left: Node, right: Node) -> Bool {
            return left.frequency == right.frequency
        }

        public let character:UInt8?
        public let frequency:Int
        public let left:Node?
        public let right:Node?

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

        public func hash(into hasher: inout Hasher) {
            hasher.combine(character)
            hasher.combine(frequency)
            hasher.combine(left)
            hasher.combine(right)
        }
    }
}

// MARK: PriorityQueue
extension CompressionTechnique.Huffman {
    public struct PriorityQueue<T: Comparable> {
        public var heap:[T]

        public init(heap: [T] = []) {
            self.heap = heap
        }

        /// - Complexity: O(_n_) where _n_ is the length of the sequence.
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

        /// - Complexity: O(_n_) where _n_ is the distance between `0` and `index`.
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
    /// Builds a Huffman tree.
    /// 
    /// - Parameters:
    ///   - frequencies: A universal frequency table.
    /// - Returns: The root node of the Huffman tree.
    /// - Complexity: O(?)
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
    /// 
    /// - Complexity: O(1).
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

// MARK: StringProtocol
extension StringProtocol {
    /// - Returns: A Huffman frequency table for the characters.
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func huffmanFrequencyTable() -> [Int] {
        var table:[Int] = Array(repeating: 0, count: 255)
        for char in self {
            for byte in char.utf8 {
                table[Int(byte)] += 1
            }
        }
        return table
    }
}