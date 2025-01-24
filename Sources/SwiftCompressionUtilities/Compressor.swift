//
//  Compressor.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

// MARK: Compressor
public protocol Compressor : AnyCompressor {
    associatedtype CompressClosureParameters

    @inlinable func compressClosure(closure: @escaping @Sendable (UInt8) -> Void) -> @Sendable (CompressClosureParameters) -> Void

    @inlinable
    func compress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int
    ) throws -> CompressionResult<[UInt8]>

    /// Compress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Returns: The number of valid bits in the last byte.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    func compress<C: Collection<UInt8>>(
        data: C,
        closure: (CompressClosureParameters) -> Void
    ) throws -> UInt8?
}

// MARK: Compress
extension Compressor {
    /// Compress a collection of bytes using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - reserveCapacity: Space to reserve for the compressed result.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    public func compress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int = 1024
    ) throws -> CompressionResult<[UInt8]> {
        var compressed:[UInt8] = []
        compressed.reserveCapacity(reserveCapacity)
        let validBitsInLastByte:UInt8 = try compress(data: data, closure: compressClosure { compressed.append($0) }) ?? 8 // TODO: fix Swift 6 error
        return CompressionResult(data: compressed, validBitsInLastByte: validBitsInLastByte)
    }

    /// Compress a collection of bytes into a stream using this technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: where _n_ is the length of `data`
    ///   - DNA binary encoding: O(_n_)
    ///   - LZ77: O(_n_)
    ///   - Snappy: O(_n_)
    @inlinable
    public func compress<C: Collection<UInt8>>(
        data: C,
        continuation: AsyncStream<UInt8>.Continuation
    ) throws {
        // TODO: finish
        let validBitsInLastByte:UInt8 = try compress(data: data, closure: compressClosure { continuation.yield($0) }) ?? 8
    }
}
extension Compressor where CompressClosureParameters == UInt8 {
    @inlinable public func compressClosure(closure: @escaping @Sendable (UInt8) -> Void) -> @Sendable (CompressClosureParameters) -> Void { closure }
}