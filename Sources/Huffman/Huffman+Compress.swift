
import SwiftCompressionUtilities

extension Huffman: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = CompressionResult<[UInt8]>?

    /// Compress a sequence of bytes using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    public func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        return data.withContiguousStorageIfAvailable { buffer in
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

    /// Compress a sequence of bytes to a stream using the Huffman Coding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func compress(
        data: some Collection<UInt8>,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> CompressionResult<AsyncStream<UInt8>>? {
        // TODO: fix
        return data.withContiguousStorageIfAvailable { buffer in
            return compress(buffer: buffer) { frequencies, codes, root in
                var vBitsInLastByte:UInt8 = 8
                let stream = AsyncStream(bufferingPolicy: limit) { continuation in
                    if let (lastByte, validBitsInLastByte) = translate(buffer: buffer, codes: codes, closure: { continuation.yield($0) }) {
                        continuation.yield(lastByte)
                        vBitsInLastByte = validBitsInLastByte
                    }
                    continuation.finish()
                }
                return CompressionResult(data: stream, rootNode: root, frequencyTable: frequencies, validBitsInLastByte: vBitsInLastByte)
            }
        } ?? nil
    }

    func compress<T>(
        buffer: UnsafeBufferPointer<UInt8>,
        closure: ([Int], [UInt8:String], Node) -> T
    ) -> T? {
        var frequencies = Array(repeating: 0, count: Int(UInt8.max-1))
        for byte in buffer {
            frequencies[Int(byte)] += 1
        }
        guard let root = buildTree(frequencies: frequencies) else { return nil }
        var codes = [UInt8:String]()
        generateCodes(node: root, codes: &codes)
        return closure(frequencies, codes, root)
    }

    /// - Complexity: O(_n_ + _m_) where _n_ is the length of `data` and _m_ is the sum of the code lengths.
    func translate(
        buffer: UnsafeBufferPointer<UInt8>,
        codes: [UInt8:String],
        closure: (UInt8) -> Void
    ) -> (lastByte: UInt8, validBits: UInt8)? {
        var builder = ByteBuilder()
        for byte in buffer {
            if let tree = codes[byte] {
                for char in tree {
                    if let wrote = builder.write(bit: char == "1") {
                        closure(wrote)
                    }
                }
            }
        }
        return builder.flush()
    }
}

// MARK: Configuration
extension Huffman {
    public struct CompressConfiguration: CompressionConfiguration, DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}