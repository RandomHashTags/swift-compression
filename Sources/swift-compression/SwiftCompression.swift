//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

@attached(member, names: arbitrary)
public macro ProtocolBuffer(
    content: [String:CompressionTechnique.Protobuf.DataType]
) = #externalMacro(module: "SwiftCompressionMacros", type: "ProtocolBuffer")

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    @inlinable
    func compress(technique: CompressionTechnique) -> CompressionResult {
        return technique.compress(data: self)
    }

    @inlinable
    func decompress(technique: CompressionTechnique) -> [UInt8] {
        return technique.decompress(data: self)
    }
}

// MARK: Stream
// TODO: support


// MARK: Foundation
#if canImport(Foundation)
import Foundation

public extension Data {
    @inlinable
    func compress(technique: CompressionTechnique) -> CompressionResult {
        return technique.compress(data: [UInt8](self))
    }

    @inlinable
    func decompress(technique: CompressionTechnique) -> [UInt8] {
        return technique.decompress(data: [UInt8](self))
    }
}

public extension Encodable {
    @inlinable
    func compress(technique: CompressionTechnique) -> CompressionResult? {
        guard let data:Data = try? JSONEncoder().encode(self) else { return nil }
        return technique.compress(data: [UInt8](data))
    }
}

public extension StringProtocol {
    @inlinable
    func compress(technique: CompressionTechnique, encoding: String.Encoding = .utf8) -> CompressionResult? {
        guard let data:Data = self.data(using: encoding) else { return nil }
        return data.compress(technique: technique)
    }
}
#endif