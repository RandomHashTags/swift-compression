
#if LZ77Compress

import ByteBuilder
import SwiftCompressionUtilities

extension LZ77: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [LZ77Token]

    /// Compress a span of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Span of bytes to compress.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        result.reserveCapacity(configuration.reserveCapacity)
        compress(span: span, closure: { result.append($0) })
        return result
    }

    /// Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - buffer: Byte buffer to compress.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `buffer`.
    package func compress(
        span: Span<UInt8>,
        closure: (LZ77Token) -> Void
    ) {
        let count = span.count
        guard count > 0 else { return }

        closure(.init(offset: 0, length: 0, char: span[0]))

        var index = 1
        while index < count {
            let currentChar = span[index]

            var bestOffset = 0
            var bestLength = 0
            let maxLength = min(lookaheadBufferSize + 1, count - index)
            var searchIndex = max(index - searchBufferSize, 0)
            while searchIndex < index {
                // TODO: use SIMD?
                if span[searchIndex] == currentChar {
                    var length = 0
                    while length < maxLength, span[searchIndex + length] == span[index + length] {
                        length += 1
                    }
                    if length >= bestLength {
                        bestLength = length
                        bestOffset = index - searchIndex
                    }
                }
                searchIndex += 1
            }

            let token:LZ77Token
            if bestLength == 0 {
                token = .init(offset: 0, length: 0, char: currentChar)
                index += 1
            } else {
                let nextSearchIndex = index + bestLength
                if nextSearchIndex < count {
                    token = .init(offset: bestOffset, length: bestLength, char: span[nextSearchIndex])
                    index = nextSearchIndex + 1
                } else {
                    let trimmedLength = bestLength - 1
                    token = .init(
                        offset: trimmedLength == 0 ? 0 : bestOffset,
                        length: trimmedLength,
                        char: span[nextSearchIndex - 1]
                    )
                    index = nextSearchIndex
                }
            }
            closure(token)
        }
    }
}

// MARK: Configuration
extension LZ77 {
    public struct CompressConfiguration: CompressionConfiguration, DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public let reserveCapacity:Int

        public init(
            reserveCapacity: Int = 1024
        ) {
            self.reserveCapacity = reserveCapacity
        }
    }
}

#endif