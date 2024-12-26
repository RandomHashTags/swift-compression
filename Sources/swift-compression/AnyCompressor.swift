//
//  AnyCompressor.swift
//
//
//  Created by Evan Anderson on 12/26/24.
//

// MARK: AnyCompressor
public protocol AnyCompressor : Sendable {
    /// The algorithm this compressor uses.
    var algorithm : CompressionAlgorithm { get }
}