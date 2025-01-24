//
//  Decompressor.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

// MARK: Decompressor
public protocol Decompressor : AnyDecompressor {
    associatedtype DecompressClosureParameters

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
    ) throws
}

// MARK: Decompress
extension Decompressor where DecompressClosureParameters == UInt8 {
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
    public func decompress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int = 1024
    ) throws -> [UInt8] {
        var decompressed:[UInt8] = []
        decompressed.reserveCapacity(reserveCapacity)
        try decompress(data: data) { decompressed.append($0) }
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
    public func decompress<C: Collection<UInt8>>(
        data: C,
        continuation: AsyncThrowingStream<UInt8, Error>.Continuation
    ) throws {
        try decompress(data: data) { continuation.yield($0) }
    }
}