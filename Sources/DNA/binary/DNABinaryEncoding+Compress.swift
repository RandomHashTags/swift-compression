
import SwiftCompressionUtilities

extension DNABinaryEncoding: Compressor {
    public typealias CompressionConfiguration = CompressConfiguration
    public typealias CompressionResult = [UInt8]

    public func compress(
        data: some Collection<UInt8>,
        configuration: CompressionConfiguration
    ) -> CompressionResult {
        var result = CompressionResult()
        let validBitsInLastByte = compress(data: data, closure: { result.append($0) })
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
    private func compress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        var bitWriter = ByteBuilder()
        for base in data {
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
    public struct CompressConfiguration: Sendable {
        public init() {
        }
    }
}