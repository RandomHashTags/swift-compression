//
//  Compressor.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

public protocol Compressor : AnyCompressor {
    associatedtype CompressClosureParameters
    associatedtype DecompressClosureParameters

    /// Compress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - closure: The logic to execute when a byte is compressed.
    /// - Returns: The number of valid bits in the last byte.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func compress<C: Collection<UInt8>>(
        data: C,
        closure: (CompressClosureParameters) -> Void
    ) -> UInt8?

    /// Decompress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - closure: The logic to execute when a byte is decompressed.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - Snappy: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (DecompressClosureParameters) -> Void
    )
}

// MARK: Compress
public extension Compressor where CompressClosureParameters == UInt8 {
    /// Compress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - reserveCapacity: The space to reserve for the compressed result.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func compress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int = 1024
    ) -> CompressionResult<[UInt8]> {
        var compressed:[UInt8] = []
        compressed.reserveCapacity(reserveCapacity)
        let validBitsInLastByte:UInt8 = compress(data: data) { compressed.append($0) } ?? 8
        return CompressionResult(data: compressed, validBitsInLastByte: validBitsInLastByte)
    }

    /// Compress a collection of bytes into a stream using this technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func compress<C: Collection<UInt8>>(
        data: C,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        // TODO: finish
        let validBitsInLastByte:UInt8 = compress(data: data) { continuation.yield($0) } ?? 8
    }
}

// MARK: Decompress
public extension Compressor where DecompressClosureParameters == UInt8 {
    /// Decompress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - reserveCapacity: The space to reserve for the compressed result.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Run-length encoding: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func decompress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int = 1024
    ) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompressed.reserveCapacity(reserveCapacity)
        decompress(data: data) { decompressed.append($0) }
        return decompressed
    }

    /// Decompress a collection of bytes into a stream using this technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Run-length encoding: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func decompress<C: Collection<UInt8>>(
        data: C,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        decompress(data: data) { continuation.yield($0) }
    }
}