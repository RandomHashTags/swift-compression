//
//  Huffman.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// https://en.wikipedia.org/wiki/Huffman_coding
public extension CompressionTechnique {
    enum Huffman {
    }
}

// MARK: Compress
public extension CompressionTechnique.Huffman {
    @inlinable
    static func compress(data: [UInt8]) -> CompressionResult<[UInt8]> {
        return compress(data: data) { codes, root in
            var compressed:[UInt8] = []
            translate(data: data, codes: codes, closure: { compressed.append($0) })
            return CompressionResult(data: compressed, rootNode: root)
        } ?? CompressionResult(data: data)
    }

    @inlinable
    static func compress(data: [UInt8]) -> (AsyncStream<UInt8>, Node?) {
        return compress(data: data) { codes, root in
            (AsyncStream { continuation in
                translate(data: data, codes: codes, closure: { continuation.yield($0) })
                continuation.finish()
            }, root)
        } ?? (AsyncStream { $0.finish() }, nil)
    }

    @inlinable
    static func compress<T>(data: [UInt8], closure: ([UInt8:String], Node) -> T) -> T? {
        var frequencies:[Int] = Array(repeating: 0, count: Int(UInt8.max-1))
        for byte in data {
            frequencies[Int(byte)] += 1
        }
        guard let root:Node = buildTree(frequencies: frequencies) else { return nil }
        var codes:[UInt8:String] = [:]
        generateCodes(root: root, codes: &codes)
        return closure(codes, root)
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
extension CompressionTechnique.Huffman {
    @inlinable
    static func decompress(data: [UInt8], root: Node?) -> [UInt8] {
        var result:[UInt8] = []
        decompress(data: data, root: root) { result.append($0) }
        return result
    }

    @inlinable
    static func decompress(data: [UInt8], root: Node?) -> AsyncStream<UInt8> {
        return AsyncStream { continuation in
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
        public mutating func push(_ element: T) {
            heap.append(element)
            siftUp(from: heap.count - 1)
        }

        @inlinable
        public mutating func pop() -> T? {
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
        public mutating func siftUp(from index: Int) {
            var index:Int = index
            while index > 0 {
                let parentIndex:Int = (index - 1) / 2
                if heap[index] >= heap[parentIndex] { break }
                heap.swapAt(index, parentIndex)
                index = parentIndex
            }
        }

        @inlinable
        public mutating func siftDown(from index: Int) {
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
    public static func buildTree(frequencies: [Int]) -> Node? {
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
    public static func generateCodes(root: Node?, code: String = "", codes: inout [UInt8:String]) {
        guard let root:Node = root else { return }
        if let char:UInt8 = root.character {
            codes[char] = code
        } else {
            generateCodes(root: root.left, code: code + "0", codes: &codes)
            generateCodes(root: root.right, code: code + "1", codes: &codes)
        }
    }
}