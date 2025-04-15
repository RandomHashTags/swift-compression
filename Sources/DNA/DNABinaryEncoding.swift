//
//  DNABinaryEncoding.swift
//
//
//  Created by Evan Anderson on 12/20/24.
//

import SwiftCompressionUtilities

extension CompressionTechnique {

    /// The DNA binary encoding compression technique.
    @inlinable
    public static func dnaBinaryEncoding(baseBits: [UInt8:[Bool]] = [
        65 : [false, false], // A
        67 : [false, true],  // C
        71 : [true, false],  // G
        84 : [true, true]    // T
    ]) -> DNABinaryEncoding {
        return DNABinaryEncoding(baseBits: baseBits)
    }

    public struct DNABinaryEncoding : Compressor, Decompressor {        
        public let baseBits:[UInt8:[Bool]]

        public init(baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ]) {
            self.baseBits = baseBits
        }

        @inlinable public var algorithm : CompressionAlgorithm { .dnaBinaryEncoding(baseBits: baseBits) }
        @inlinable public var quality : CompressionQuality { .lossless }

        public var baseBitsReversed : [[Bool]:UInt8] {
            var reversed:[[Bool]:UInt8] = [:]
            reversed.reserveCapacity(baseBits.count)
            for (byte, bits) in baseBits {
                reversed[bits] = byte
            }
            return reversed
        }
    }
}

// MARK: Compress
extension CompressionTechnique.DNABinaryEncoding {
    /// Compress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - baseBits: Bit codes for the unique base nucleotides.
    ///   - closure: Logic to execute when a byte was encoded.
    /// - Returns: Valid bits for the last byte, if necessary.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<S: Collection<UInt8>>(
        data: S,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        var bitWriter:ByteBuilder = .init()
        for base in data {
            if let bits = baseBits[base] {
                for bit in bits {
                    if let wrote = bitWriter.write(bit: bit) {
                        closure(wrote)
                    }
                }
            }
        }
        guard let (byte, validBits) = bitWriter.flush() else { return nil }
        closure(byte)
        return validBits
    }
}

// MARK: Decompress
extension CompressionTechnique.DNABinaryEncoding {
    /// Decompress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a given base nucleotide is found.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<S: Collection<UInt8>>(
        data: S,
        closure: (UInt8) -> Void
    ) {
        let reversed = baseBitsReversed
        for byte in data {
            var bits:[Bool] = []
            bits.reserveCapacity(4)
            for bit in byte.bits {
                bits.append(bit)
                if let base = reversed[bits] {
                    closure(base)
                    bits.removeAll(keepingCapacity: true)
                }
            }
        }
    }
}