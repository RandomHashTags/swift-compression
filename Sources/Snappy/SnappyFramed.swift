//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 1/23/25.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The Snappy Framed compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)
    /// 
    /// https://github.com/google/snappy
    public static let snappyFramed:SnappyFramed = SnappyFramed()

    public struct SnappyFramed : Compressor, Decompressor {        
        @inlinable public var algorithm : CompressionAlgorithm { .snappyFramed }
        @inlinable public var quality : CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.SnappyFramed { // TODO: finish
    /// - Parameters:
    ///   - data: A sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.SnappyFramed { // TODO: finish
    /// - Parameters:
    ///   - data: A collection of bytes to decompress.
    ///   - closure: The logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) {
    }
}