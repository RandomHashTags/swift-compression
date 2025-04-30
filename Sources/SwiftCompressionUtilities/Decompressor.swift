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
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Run-length encoding: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (DecompressClosureParameters) -> Void
    ) throws(DecompressionError)
}

// MARK: Decompress
extension Decompressor where DecompressClosureParameters == UInt8 {
    /// Decompress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - reserveCapacity: Space to reserve for the decompressed result (if no length was decompressed).
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Run-length encoding: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    public func decompress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int = 1024
    ) throws(DecompressionError) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompressed.reserveCapacity(reserveCapacity)
        try decompress(data: data) { decompressed.append($0) }
        return decompressed
    }

    /// Decompress a collection of bytes into a stream using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - continuation: The `AsyncThrowingStream<UInt8, Error>.Continuation`.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Run-length encoding: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func decompress<C: Collection<UInt8>>(
        data: C,
        continuation: AsyncThrowingStream<UInt8, Error>.Continuation
    ) throws(DecompressionError) {
        try decompress(data: data) { continuation.yield($0) }
    }
}