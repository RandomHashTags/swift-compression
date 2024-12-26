//
//  AnyCompressor.swift
//
//
//  Created by Evan Anderson on 12/26/24.
//

// MARK: AnyCompressorProtocol
public protocol AnyCompressor : Sendable {
    /// The algorithm this compressor uses.
    var algorithm : CompressionAlgorithm { get }
}