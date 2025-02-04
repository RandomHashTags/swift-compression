//
//  LZ78.swift
//
//
//  Created by Evan Anderson on 12/25/24.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The LZ78 compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    public enum LZ78 {
        typealias Entry = (Int, UInt8)
    }
}

// MARK: Compress
extension CompressionTechnique.LZ78 {
    public static func compress<S: Sequence<UInt8>>(
        data: S,
        endOfFileMarker: UInt8?
    ) -> [UInt8] {
        let compressed:[UInt8] = []
        /*
        var set:Set<UInt8> = Set(minimumCapacity: 256)
        var array:[Entry] = [(0, 0)]
        for byte in data {
            if !set.contains(byte) {
            }
        }
        
        for (lastMatchingIndex, byte) in array {
            //compressed.append(lastMatchingIndex)
        }
        if let endOfFileMarker:UInt8 = endOfFileMarker {
            compressed.append(endOfFileMarker)
        }*/
        return compressed
    }
}