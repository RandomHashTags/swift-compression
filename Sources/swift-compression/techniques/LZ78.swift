//
//  LZ78.swift
//
//
//  Created by Evan Anderson on 12/25/24.
//

public extension CompressionTechnique {
    /// The LZ78 compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    enum LZ78 {
        typealias Entry = (Int, UInt8)
    }
}

// MARK: Compress
public extension CompressionTechnique.LZ78 {
    static func compress<S: Sequence<UInt8>>(
        data: S,
        endOfFileMarker: UInt8?
    ) -> [UInt8] {
        var set:Set<UInt8> = Set(minimumCapacity: 256)
        var array:[Entry] = [(0, 0)]
        for byte in data {
            if !set.contains(byte) {
            }
        }
        var compressed:[UInt8] = []
        for (lastMatchingIndex, byte) in array {
            //compressed.append(lastMatchingIndex)
        }
        if let endOfFileMarker:UInt8 = endOfFileMarker {
            compressed.append(endOfFileMarker)
        }
        return compressed
    }
}