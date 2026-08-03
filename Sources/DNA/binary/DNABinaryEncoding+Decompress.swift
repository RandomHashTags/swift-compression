
import SwiftCompressionUtilities

extension DNABinaryEncoding: Decompressor {
    public typealias ConcreteDecompressionConfiguration = CompressConfiguration

    /// Decompress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a given base nucleotide is found.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> ConcreteDecompressionResult {
        var result = ConcreteDecompressionResult()
        decompress(data: data, closure: { result.append($0) })
        return result
    }

    /// Decompress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a given base nucleotide is found.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    private func decompress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) {
        let reversed = baseBitsReversed
        for byte in data {
            if let base = reversed[byte & 3] {
                closure(base)
            }
            if let base = reversed[(byte & 12) >> 2] {
                closure(base)
            }
            if let base = reversed[(byte & 48) >> 4] {
                closure(base)
            }
            if let base = reversed[(byte & 192) >> 6] {
                closure(base)
            }
        }
    }
}