//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

// MARK: String
public extension String {
    func compress(technique: CompressionTechnique, encoding: String.Encoding = .utf8) -> CompressionResult? {
        guard let data:Data = self.data(using: encoding) else { return nil }
        return data.compress(technique: technique)
    }
}

// MARK: Data
public extension Data {
    func compress(technique: CompressionTechnique) -> CompressionResult {
        return technique.compress(data: self)
    }
    func decompress(technique: CompressionTechnique) -> Data {
        return technique.decompress(data: self)
    }
}

// MARK: Stream
// TODO: support