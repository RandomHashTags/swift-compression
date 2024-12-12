//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

// MARK: Data
public extension Data {
    @inlinable
    func compress(technique: CompressionTechnique) -> CompressionResult {
        return technique.compress(data: self)
    }

    @inlinable
    func decompress(technique: CompressionTechnique) -> Data {
        return technique.decompress(data: self)
    }
}

// MARK: Encodable
public extension Encodable {
    @inlinable
    func compress(technique: CompressionTechnique) -> CompressionResult? {
        guard let data:Data = try? JSONEncoder().encode(self) else { return nil }
        return technique.compress(data: data)
    }
}

// MARK: StringProtocol
public extension StringProtocol {
    @inlinable
    func compress(technique: CompressionTechnique, encoding: String.Encoding = .utf8) -> CompressionResult? {
        guard let data:Data = self.data(using: encoding) else { return nil }
        return data.compress(technique: technique)
    }
}

// MARK: [UInt8]
public extension Sequence where Element == UInt8 {
    @inlinable
    func compress(technique: CompressionTechnique) -> CompressionResult {
        return technique.compress(data: Data(self))
    }

    @inlinable
    func decompress(technique: CompressionTechnique) -> Data {
        return technique.decompress(data: Data(self))
    }
}

// MARK: Stream
// TODO: support