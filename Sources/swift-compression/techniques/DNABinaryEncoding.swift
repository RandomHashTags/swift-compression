//
//  DNABinaryEncoding.swift
//
//
//  Created by Evan Anderson on 12/20/24.
//

public extension CompressionTechnique {

    /// The DNA binary encoding compression technique.
    @inlinable
    static func dnaBinaryEncoding(baseBits: [UInt8:[Bool]] = [
        65 : [false, false], // A
        67 : [false, true],  // C
        71 : [true, false],  // G
        84 : [true, true]    // T
    ]) -> DNABinaryEncoding {
        return DNABinaryEncoding(baseBits: baseBits)
    }

    struct DNABinaryEncoding : Compressor {
        public let baseBits:[UInt8:[Bool]]

        public init(baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ]) {
            self.baseBits = baseBits
        }

        public var rawValue : String { "dnaBinaryEncoding" }

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
public extension CompressionTechnique.DNABinaryEncoding {
    /// Compress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - closure: The logic to execute when a byte was encoded.
    /// - Returns: The valid bits for the last byte, if necessary.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress<S: Collection<UInt8>>(
        data: S,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        var bitWriter:ByteBuilder = .init()
        for base in data {
            if let bits:[Bool] = baseBits[base] {
                for bit in bits {
                    if let wrote:UInt8 = bitWriter.write(bit: bit) {
                        closure(wrote)
                    }
                }
            }
        }
        guard let (byte, validBits):(UInt8, UInt8) = bitWriter.flush() else { return nil }
        closure(byte)
        return validBits
    }
}

// MARK: Decompress
public extension CompressionTechnique.DNABinaryEncoding {
    /// Decompress a collection of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - closure: The logic to execute when a given base nucleotide is found.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func decompress<S: Collection<UInt8>>(
        data: S,
        closure: (UInt8) -> Void
    ) {
        let reversed:[[Bool]:UInt8] = baseBitsReversed
        for byte in data {
            var bits:[Bool] = []
            bits.reserveCapacity(4)
            for bit in byte.bits {
                bits.append(bit)
                if let base:UInt8 = reversed[bits] {
                    closure(base)
                    bits.removeAll(keepingCapacity: true)
                }
            }
        }
    }
}