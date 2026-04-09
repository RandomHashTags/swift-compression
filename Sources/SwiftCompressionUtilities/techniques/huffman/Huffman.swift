
/// The Huffman coding compression technique.
/// 
/// https://en.wikipedia.org/wiki/Huffman_coding
public struct Huffman: Sendable {
    public init() {
    }

    public var algorithm: CompressionAlgorithm {
        .huffmanCoding
    }

    public var compressionQuality: CompressionQuality {
        .lossless
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