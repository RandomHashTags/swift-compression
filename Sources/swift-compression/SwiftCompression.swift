//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: Sequence
public extension Sequence where Element == UInt8 {
    /// Compress a copy of this data using the specified technique(s).
    /// - Returns: The `CompressionResult`.
    @inlinable
    func compressed(using technique: CompressionTechnique) -> CompressionResult<[UInt8]>? {
        return technique.compress(data: self)
    }

    /// Decompress this data using the specified technique(s).
    /// - Returns: The decompressed data.
    @inlinable
    func decompressed(using technique: CompressionTechnique) -> [UInt8] {
        return technique.decompress(data: [UInt8](self))
    }
}

#if canImport(Foundation)
// MARK: Foundation
import Foundation

public extension Data {
    /// Compress a copy of this data using the specified technique(s).
    /// - Returns: The `CompressionResult`.
    @inlinable
    func compressed(using technique: CompressionTechnique) -> CompressionResult<[UInt8]>? {
        return technique.compress(data: [UInt8](self))
    }

    /// Decompress this data using the specified technique(s).
    /// - Returns: The decompressed data.
    @inlinable
    func decompressed(using technique: CompressionTechnique) -> Data {
        return Data(technique.decompress(data: [UInt8](self)))
    }
}

public extension StringProtocol {
    @inlinable
    func compressed(using technique: CompressionTechnique, encoding: String.Encoding = .utf8) -> CompressionResult<[UInt8]>? {
        guard let data:Data = self.data(using: encoding) else { return nil }
        return data.compressed(using: technique)
    }
}
#endif