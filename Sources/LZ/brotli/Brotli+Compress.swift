
import SwiftCompressionUtilities

extension Brotli { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}