//
//  LZ77.swift
//
//
//  Created by Evan Anderson on 12/12/24.
//

import Foundation

public enum LZ77 { // TODO: finish
    typealias Token = (distance: Int, length: Int, next: UInt8)
}

// MARK: Compress data
public extension LZ77 {
    @inlinable
    static func compress(data: Data, windowSize: Int, bufferSize: Int) -> CompressionResult {
        return CompressionResult(data: data)
    }
}

extension LZ77 {
    static func compressTokens(data: Data, windowSize: Int, bufferSize: Int) -> [Token] {
        var compressed:[Token] = []
        var startingPositions:[Key:Int] = [:]
        var index:Int = 0
        while index < data.count {
            let windowStarts:Int = max(0, index - windowSize)
            var distance:Int = 0, length:Int = 0
            var next:UInt8 = data[index]
            let lookAhead:Data = data[index..<min(index + bufferSize, data.count)]
            if let match:Int = startingPositions[Key(lookAhead[0], lookAhead[1])] {
                distance = index - match
                length = 2
                if index + length < data.count {
                    next = data[index + length]
                }
            }
            compressed.append((distance, length, next))

            let search:Data = data[windowStarts..<index]
            for i in windowStarts..<index {
                let keyData:Data = search[i..<min(i + 2, search.count)]
                let key:Key = Key(keyData[0], keyData[1])
                startingPositions[key] = i
            }
            index += length + 1
        }
        return compressed
    }
}

extension LZ77 {
    struct Key : Hashable {
        let first:UInt8
        let second:UInt8

        init(_ first: UInt8, _ second: UInt8) {
            self.first = first
            self.second = second
        }
    }
}

// MARK: Decompress data
public extension LZ77 {
    @inlinable
    static func decompress(data: Data) -> Data {
        return data
    }
}