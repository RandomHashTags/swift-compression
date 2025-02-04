//
//  IWA.swift
//
//
//  Created by Evan Anderson on 1/23/25.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The iWork Archive (iwa) compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/IWork
    @inlinable
    public static func iwa(version: IWAVersion) -> IWA {
        return IWA(version: version)
    }

    public struct IWA : Compressor, Decompressor {        
        /// Version of the iWork Archive to use.
        public let version:IWAVersion

        public init(version: IWAVersion) {
            self.version = version
        }

        @inlinable public var algorithm : CompressionAlgorithm { .iwa(version: version) }
        @inlinable public var quality : CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.IWA { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.IWA { // TODO: finish
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) {
    }
}