//
//  DNABinaryEncoding.swift
//
//
//  Created by Evan Anderson on 12/20/24.
//

public extension CompressionTechnique {
    /// The DNA binary encoding compression technique.
    enum DNABinaryEncoding {
    }
}

// MARK: Compress
public extension CompressionTechnique.DNABinaryEncoding {
    /// Compress a sequence of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S,
        baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ]
    ) -> CompressionResult<[UInt8]> {
        var compressed:[UInt8] = []
        let validBits:UInt8 = compress(data: data, baseBits: baseBits) { compressed.append($0) } ?? 8
        return CompressionResult(data: compressed, validBitsInLastByte: validBits)
    }

    /// Compress a sequence of bytes into a stream using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S,
        baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            if let validBits:UInt8 = compress(data: data, baseBits: baseBits, closure: { continuation.yield($0) }) {
                // TODO: fix
            }
            continuation.finish()
        }
    }

    /// Compress a sequence of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - closure: The logic to execute when a byte was encoded.
    /// - Returns: The valid bits for the last byte, if necessary.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S,
        baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ],
        closure: (UInt8) -> Void
    ) -> UInt8? {
        var bitWriter:CompressionTechnique.IntBitBuilder = .init()
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

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compresses this data using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - baseBits: The bit codes for the unique base nucleotides.
    /// - Returns: `self`.
    /// - Complexity: O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func compressDNABinaryEncoding(
        baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ]
    ) -> Self {
        self = CompressionTechnique.DNABinaryEncoding.compress(data: self, baseBits: baseBits).data
        return self
    }

    /// Compress a copy of this data using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - baseBits: The bit codes for the unique base nucleotides.
    /// - Returns: The compressed data.
    /// - Complexity: O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressedDNABinaryEncoding(
        baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ]
    ) -> CompressionResult<[UInt8]> {
        return CompressionTechnique.DNABinaryEncoding.compress(data: self, baseBits: baseBits)
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Compress this data to a stream using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Returns: An `AsyncStream<UInt8>` that decompresses the data.
    /// - Complexity: O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressDNABinaryEncoding(
        baseBits: [UInt8:[Bool]] = [
            65 : [false, false], // A
            67 : [false, true],  // C
            71 : [true, false],  // G
            84 : [true, true]    // T
        ],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.DNABinaryEncoding.compress(data: self, baseBits: baseBits, bufferingPolicy: limit)
    }
}

// MARK: Decompress
public extension CompressionTechnique.DNABinaryEncoding {
    /// Decompress a sequence of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress<S: Sequence<UInt8>>(
        data: S,
        baseBits: [[Bool]:UInt8] = [
            [false, false] : 65, // A
            [false, true] : 67,  // C
            [true, false] : 71,  // G
            [true, true] : 84    // T
        ]
    ) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompress(data: data, baseBits: baseBits) { decompressed.append($0) }
        return decompressed
    }

    /// Decompress a sequence of bytes into a stream using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress<S: Sequence<UInt8>>(
        data: S,
        baseBits: [[Bool]:UInt8] = [
            [false, false] : 65, // A
            [false, true] : 67,  // C
            [true, false] : 71,  // G
            [true, true] : 84    // T
        ],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            decompress(data: data, baseBits: baseBits) { continuation.yield($0) }
            continuation.finish()
        }
    }

    /// Decompress a sequence of bytes using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - closure: The logic to execute when a given base nucleotide is found.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress<S: Sequence<UInt8>>(
        data: S,
        baseBits: [[Bool]:UInt8] = [
            [false, false] : 65, // A
            [false, true] : 67,  // C
            [true, false] : 71,  // G
            [true, true] : 84    // T
        ],
        closure: (UInt8) -> Void
    ) {
        for byte in data {
            var bits:[Bool] = []
            bits.reserveCapacity(4)
            for bit in byte.bits {
                bits.append(bit)
                if let base:UInt8 = baseBits[bits] {
                    closure(base)
                    bits.removeAll(keepingCapacity: true)
                }
            }
        }
    }
}

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Decompresses this data using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - baseBits: The bit codes for the unique base nucleotides.
    /// - Returns: `self`.
    /// - Complexity: O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func decompressDNABinaryEncoding(baseBits: [[Bool]:UInt8] = [
            [false, false] : 65, // A
            [false, true] : 67,  // C
            [true, false] : 71,  // G
            [true, true] : 84    // T
        ]
    ) -> Self {
        self = CompressionTechnique.DNABinaryEncoding.decompress(data: self, baseBits: baseBits)
        return self
    }

    /// Decompress a copy of this data using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - baseBits: The bit codes for the unique base nucleotides.
    /// - Returns: The compressed data.
    /// - Complexity: O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompressedDNABinaryEncoding(baseBits: [[Bool]:UInt8] = [
            [false, false] : 65, // A
            [false, true] : 67,  // C
            [true, false] : 71,  // G
            [true, true] : 84    // T
        ]
    ) -> [UInt8] {
        return CompressionTechnique.DNABinaryEncoding.decompress(data: self, baseBits: baseBits)
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Decompress this data to a stream using the DNA binary encoding technique.
    /// 
    /// - Parameters:
    ///   - baseBits: The bit codes for the unique base nucleotides.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Returns: An `AsyncStream<UInt8>` that decompresses the data.
    /// - Complexity: O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompressDNABinaryEncoding(
        baseBits: [[Bool]:UInt8] = [
            [false, false] : 65, // A
            [false, true] : 67,  // C
            [true, false] : 71,  // G
            [true, true] : 84    // T
        ],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.DNABinaryEncoding.decompress(data: self, baseBits: baseBits, bufferingPolicy: limit)
    }
}