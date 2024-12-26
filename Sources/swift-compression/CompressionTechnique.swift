//
//  CompressionTechnique.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: CompressionTechnique
/// A collection of well-known and useful compression and decompression technique implementations.
public enum CompressionTechnique {
}

// MARK: Frequency tables
public extension CompressionTechnique {
    /// Creates a universal frequency table from a sequence of raw bytes.
    /// 
    /// - Parameters:
    ///   - data: A sequence of raw bytes.
    /// - Returns: A universal frequency table.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func buildFrequencyTable<S: Sequence<UInt8>>(data: S) -> [Int] {
        var table:[Int] = Array(repeating: 0, count: 255)
        for byte in data {
            table[Int(byte)] += 1
        }
        return table
    }

    /// Creates a lookup frequency table from a sequence of raw bytes.
    /// 
    /// - Parameters:
    ///   - data: A sequence of raw bytes.
    /// - Returns: A lookup frequency table.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func buildFrequencyTable<S: Sequence<UInt8>>(data: S) -> [UInt8:Int] {
        var table:[UInt8:Int] = [:]
        for byte in data {
            table[byte, default: 0] += 1
        }
        return table
    }

    /// Creates a universal frequency table from a character frequency dictionary.
    /// 
    /// - Parameters:
    ///   - chars: A frequency table that represents how many times a character is present.
    /// - Returns: A universal frequency table.
    /// - Complexity: O(_n_) where _n_ is the sum of the `Character` utf8 lengths in `chars`.
    @inlinable
    static func buildFrequencyTable(chars: [Character:Int]) -> [Int] {
        var table:[Int] = Array(repeating: 0, count: 255)
        for (char, freq) in chars {
            for byte in char.utf8 {
                table[Int(byte)] = freq
            }
        }
        return table
    }
}