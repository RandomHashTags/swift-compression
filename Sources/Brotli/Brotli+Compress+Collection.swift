
#if BrotliCompressCollection

import BrotliShim
import SwiftCompressionUtilities

extension Brotli {
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        _ collection: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var outLength = collection.count
        let maxSize = BrotliEncoderMaxCompressedSize(outLength)
        return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: maxSize, { outBuffer in
            let success = collection.withContiguousStorageIfAvailable {
                return BrotliEncoderCompress(
                    quality,
                    windowSize,
                    BrotliEncoderMode(rawValue: mode),
                    outLength,
                    $0.baseAddress,
                    &outLength,
                    outBuffer.baseAddress
                )
            } ?? BROTLI_FALSE
            return success == BROTLI_TRUE ? [UInt8](outBuffer.prefix(outLength)) : nil
        })
    }
}

#endif