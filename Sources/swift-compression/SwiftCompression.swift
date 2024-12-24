//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: Collection
public extension Collection where Element == UInt8 {
    /// Compress a copy of this data using the specified technique(s).
    /// 
    /// - Returns: The `CompressionResult`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressed(using technique: CompressionTechnique) -> CompressionResult<[UInt8]>? {
        return technique.compress(data: self)
    }

    /// Decompress the sequence of bytes using the specified technique(s).
    /// 
    /// - Returns: The decompressed bytes.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompressed(using technique: CompressionTechnique) -> [UInt8] {
        return technique.decompress(data: [UInt8](self))
    }
}

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func compress(using technique: CompressionTechnique) -> Self {
        self = technique.compress(data: self)?.data ?? []
        return self
    }

    /// Decompress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func decompress(using technique: CompressionTechnique) -> Self {
        self = technique.decompress(data: self)
        return self
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Decompress this data to a stream using the specified technique(s).
    /// 
    /// - Parameters:
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Returns: An `AsyncStream<UInt8>` that receives a decompressed byte.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompress(
        using technique: CompressionTechnique,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return technique.decompress(data: self, bufferingPolicy: limit)
    }
}

#if canImport(Foundation)
// MARK: Foundation
import Foundation

public extension Data {
    /// Compress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func compress(using technique: CompressionTechnique) -> Self {
        if let compressed:[UInt8] = technique.compress(data: [UInt8](self))?.data {
            self = Data(compressed)
        } else {
            self = Data()
        }
        return self
    }

    /// Compress a copy of this data using the specified technique(s).
    /// 
    /// - Returns: The `CompressionResult`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressed(using technique: CompressionTechnique) -> CompressionResult<[UInt8]>? {
        return technique.compress(data: [UInt8](self))
    }

    /// Decompress this data using the specified technique(s).
    /// - Returns: The decompressed data.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompressed(using technique: CompressionTechnique) -> Data {
        return Data(technique.decompress(data: [UInt8](self)))
    }
}

public extension StringProtocol {
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressed(using technique: CompressionTechnique, encoding: String.Encoding = .utf8) -> CompressionResult<[UInt8]>? {
        guard let data:Data = self.data(using: encoding) else { return nil }
        return data.compressed(using: technique)
    }
}
#endif