
import ByteBuilder
import SwiftCompressionUtilities

extension DNABinaryEncoding: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        let validBitsInLastByte = compress(span: span, closure: { result.append($0) })
        return result
    }

    /// Compress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - span: Collection of bytes to compress.
    ///   - closure: Logic to execute when a byte was encoded.
    /// - Returns: Valid bits for the last byte, if necessary.
    /// - Complexity: O(_n_) where _n_ is the length of `span`.
    func compress(
        span: Span<UInt8>,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        var byteBuilder = ByteBuilder()
        for i in span.indices {
            if let bits = baseBits[span[i]] {
                byteBuilder.write(amount: 2, bits: bits, closure: closure)
            }
        }
        guard let (byte, validBits) = byteBuilder.flush() else { return nil }
        closure(byte)
        return validBits
    }
}

// MARK: Configuration
extension DNABinaryEncoding {
    public struct CompressConfiguration: CompressionConfiguration, DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}