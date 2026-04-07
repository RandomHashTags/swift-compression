
extension DNABinaryEncoding {
    /// Decompress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a given base nucleotide is found.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) {
        let reversed = baseBitsReversed
        for byte in data {
            var bits = [Bool]()
            bits.reserveCapacity(4)
            for bit in byte.bits {
                bits.append(bit)
                if let base = reversed[bits] {
                    closure(base)
                    bits.removeAll(keepingCapacity: true)
                }
            }
        }
    }
}