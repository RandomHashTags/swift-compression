//
//  CSS.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

import SwiftCompressionUtilities

extension CompressionTechnique {

    /// CSS compression techniques.
    public static let css:CSS = CSS()

    public struct CSS : Compressor {
        @inlinable public var algorithm : CompressionAlgorithm { .programmingLanguage(.css) }
        @inlinable public var quality : CompressionQuality { .lossy }
    }
}

// MARK: Compress
extension CompressionTechnique.CSS {
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, reserveCapacity: Int) throws -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation // TODO: support?
    }

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<S: Sequence<UInt8>>(data: S, closure: (UInt8) -> Void) -> UInt8? {
        return nil // TODO: support?
    }
}

// MARK: Minify
extension CompressionTechnique.CSS {
    /// Optimizes CSS code to make it suitable for production-only usage, which results in the minimum binary size required to represent the same code.
    /// 
    /// Optionally removes comments and unnecessary whitespace
    @inlinable
    public func minify<C: Collection<UInt8>>(data: C, reserveCapacity: Int) -> [UInt8] {
        var index:Int = 0
        let count:Int = data.count
        var i:Int = 0, result:[UInt8] = .init(repeating: 0, count: count)

        let space:UInt8 = 32
        let pound:UInt8 = 35
        let lineFeed:UInt8 = 10
        let carriageReturn:UInt8 = 13
        let asterisk:UInt8 = 42
        let horizontalTab:UInt8 = 9
        let period:UInt8 = 46
        let forwardSlash:UInt8 = 47
        let a:UInt8 = 97
        let c:UInt8 = 99
        let d:UInt8 = 100
        let l:UInt8 = 108
        let n:UInt8 = 110
        while data[i] == space || data[i] == horizontalTab || data[i] == lineFeed || data[i] == carriageReturn {
            i += 1
        }
        var calcDepth:UInt8 = 0
        while i < count {
            let character:UInt8 = data[i]
            switch character {
            case space,
                horizontalTab,
                lineFeed,
                carriageReturn:
                if calcDepth > 0 {
                    assign(byte: character, to: &index, in: &result)
                } else {
                    let next:UInt8 = data[i+1]
                    let iMinus1:UInt8 = data[i-1]
                    if iMinus1.char.isLetter && (next == pound || next == period || next.char.isNumber || next.char.isLetter || iMinus1 == d && data[i-2] == n && data[i-3] == a) {
                        assign(byte: character, to: &index, in: &result)
                    }
                }
            case forwardSlash:
                if data[i+1] == asterisk {
                    i += 2
                    for j in i..<count {
                        if data[j] == asterisk && data[j+1] == forwardSlash {
                            i = j+1
                            break
                        }
                    }
                } else {
                    assign(byte: character, to: &index, in: &result)
                }
            case 40: // (
                if calcDepth > 0 || data[i-1] == c && data[i-2] == l && data[i-3] == a && data[i-4] == c { // in calc or calc( was found
                    calcDepth += 1
                }
                assign(byte: character, to: &index, in: &result)
            case 41: // )
                if calcDepth > 0 {
                    calcDepth -= 1
                }
                assign(byte: character, to: &index, in: &result)
            default:
                assign(byte: character, to: &index, in: &result)
            }
            i += 1
        }
        return [UInt8](result[0..<index])
    }
    @inlinable
    func assign(byte: UInt8, to index: inout Int, in data: inout [UInt8]) {
        data[index] = byte
        index += 1
    }
}

extension UInt8 {
    @inlinable var char : Character { Character(UnicodeScalar(self)) }
}