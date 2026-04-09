
/// The Huffman coding compression technique.
/// 
/// https://en.wikipedia.org/wiki/Huffman_coding
public enum Huffman: Sendable {
    public var algorithm: CompressionAlgorithm {
        .huffmanCoding
    }

    public var quality: CompressionQuality {
        .lossless
    }
}

// MARK: Decompress
extension Huffman {
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - root: The root Huffman Node.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(data: [UInt8], root: Node?) -> [UInt8] {
        var result = [UInt8]()
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
    public func decompress(data: [UInt8], root: Node?, closure: (UInt8) -> Void) {
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
    /// Decompress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - frequencyTable: A Huffman frequency table of characters.
    // /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the length of `frequencyTable`. // TODO: FIX
    public func decompress(data: [UInt8], frequencyTable: [Int]) -> [UInt8] {
        guard let root = buildTree(frequencies: frequencyTable) else { return data }
        return decompress(data: data, root: root)
    }

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
    
    public func decompress(data: [UInt8], frequencyTable: [Int], closure: (UInt8) -> Void) {
        guard let root = buildTree(frequencies: frequencyTable) else { return }
        decompress(data: data, root: root, closure: closure)
    }

    public func decompress(data: [UInt8], codes: [[Bool]:UInt8], closure: (UInt8) -> Void) {
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

// MARK: Node
extension Huffman {
    /// A Huffman Node.
    public final class Node: Comparable, Hashable, Sendable {
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
extension Huffman {
    public struct PriorityQueue<T: Comparable> {
        public var heap:[T]

        public init(heap: [T] = []) {
            self.heap = heap
        }

        /// - Complexity: O(_n_) where _n_ is the length of the sequence.
        mutating func push(_ element: T) {
            heap.append(element)
            siftUp(from: heap.count - 1)
        }

        mutating func pop() -> T? {
            guard !heap.isEmpty else { return nil }
            if heap.count == 1 {
                return heap.removeLast()
            }
            let root = heap[0]
            heap[0] = heap.removeLast()
            siftDown(from: 0)
            return root
        }

        /// - Complexity: O(_n_) where _n_ is the distance between `0` and `index`.
        mutating func siftUp(from index: Int) {
            var index = index
            while index > 0 {
                let parentIndex = (index - 1) / 2
                if heap[index] >= heap[parentIndex] { break }
                heap.swapAt(index, parentIndex)
                index = parentIndex
            }
        }

        mutating func siftDown(from index: Int) {
            let element = heap[index]
            let count = heap.count
            var index = index
            while true {
                let leftIndex = (2 * index) + 1
                let rightIndex = leftIndex + 1
                var minIndex = index
                
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
extension Huffman {
    /// Builds a Huffman tree.
    /// 
    /// - Parameters:
    ///   - frequencies: A universal frequency table.
    /// - Returns: The root node of the Huffman tree.
    /// - Complexity: O(?)
    func buildTree(frequencies: [Int]) -> Node? {
        var queue = PriorityQueue<Node>()
        for (char, freq) in frequencies.enumerated() {
            if freq != 0 {
                queue.push(Node(character: UInt8(char), frequency: freq))
            }
        }
        while queue.heap.count > 1 {
            let left = queue.pop()!
            let right = queue.pop()!
            let merged = Node(frequency: left.frequency + right.frequency, left: left, right: right)
            queue.push(merged)
        }
        return queue.pop()
    }

    /// Generates the binary codes for a node.
    /// 
    /// - Complexity: O(1).
    func generateCodes(node: Node?, code: String = "", codes: inout [UInt8:String]) {
        guard let node else { return }
        if let char = node.character {
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
    public func huffmanFrequencyTable() -> [Int] {
        var table = Array(repeating: 0, count: 255)
        for char in self {
            for byte in char.utf8 {
                table[Int(byte)] += 1
            }
        }
        return table
    }
}