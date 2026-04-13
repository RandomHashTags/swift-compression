
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
        let validBitsInLastByte = span.withUnsafeBufferPointer {
            compress(buffer: $0, closure: { result.append($0) })
        }
        return result
    }

    /// Compress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - baseBits: Bit codes for the unique base nucleotides.
    ///   - closure: Logic to execute when a byte was encoded.
    /// - Returns: Valid bits for the last byte, if necessary.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    func compress(
        buffer: UnsafeBufferPointer<UInt8>,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        var bitWriter = ByteBuilder()
        for base in buffer {
            if let bits = baseBits[base] {
                for bit in bits {
                    if let wrote = bitWriter.write(bit: bit) {
                        closure(wrote)
                    }
                }
            }
        }
        guard let (byte, validBits) = bitWriter.flush() else { return nil }
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