//
//  LZ77.swift
//
//
//  Created by Evan Anderson on 12/12/24.
//

public enum LZ77 { // TODO: finish
    typealias Token = (distance: Int, length: Int, next: UInt8)
}

// MARK: Compress data
public extension LZ77 {
    @inlinable
    static func compress(data: [UInt8], windowSize: Int, bufferSize: Int) -> CompressionResult {
        return CompressionResult(data: data)
    }
}

extension LZ77 {
    typealias KeyType = Key<UInt8, UInt8>

    static func compressTokens(data: [UInt8], windowSize: Int, bufferSize: Int) -> [Token] {
        var compressed:[Token] = []    
        var startingPositions:[KeyType:Int] = [:]
        var index:Int = 0
        while index < data.count {
            let windowStarts:Int = max(0, index - windowSize)
            var distance:Int = 0, length:Int = 0
            var next:UInt8 = data[index]
            let lookAhead:ArraySlice<UInt8> = data[index..<min(index + bufferSize, data.count)]
            let key:KeyType = Key(chars: (lookAhead[0], lookAhead[1]))
            if let match:Int = startingPositions[key] {
                distance = index - match
                length = key.count
                if index + length < data.count {
                    next = data[index + length]
                }
            }
            compressed.append((distance, length, next))

            let search:ArraySlice<UInt8> = data[windowStarts..<index]
            for i in windowStarts..<index {
                let keyData:ArraySlice<UInt8> = search[i..<min(i + 2, search.count)]
                let key:KeyType = Key(chars: (keyData[0], keyData[1]))
                startingPositions[key] = i
            }
            index += length + 1
        }
        return compressed
    }
}

extension LZ77 {
    struct Key<each T : FixedWidthInteger> : Hashable {
        static func == (left: Self, right: Self) -> Bool {
            for (l, r) in repeat (each left.chars, each right.chars) {
                if l != r { return false }
            }
            return true
        }

        let chars:(repeat each T)

        var count : Int {
            var i:Int = 0
            for _ in repeat (each chars) {
                i += 1
            }
            return i
        }

        func hash(into hasher: inout Hasher) {
            for i in repeat (each chars) {
                hasher.combine(i)
            }
        }
    }
}

// MARK: Decompress data
public extension LZ77 {
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        return data
    }
}