//
//  Snappy.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The Snappy (Zippy) compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)
    /// 
    /// https://github.com/google/snappy
    @inlinable
    public static func snappy(windowSize: Int = Int(UInt16.max)) -> Snappy {
        return Snappy(windowSize: windowSize)
    }

    public struct Snappy : Compressor, Decompressor {

        /// Size of the window.
        public let windowSize:Int

        public init(windowSize: Int = Int(UInt16.max)) {
            self.windowSize = windowSize
        }

        @inlinable public var algorithm : CompressionAlgorithm { .snappy(windowSize: windowSize) }
        @inlinable public var quality : CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.Snappy {
    public func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) throws(CompressionError) -> UInt8? {
        return nil
    }
    public func compress<C: Collection<UInt8>>(data: C, reserveCapacity: Int) throws -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation
    }
}
/*
extension CompressionTechnique.Snappy { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) -> UInt8? {
        var index:C.Index = data.startIndex
        while index != data.endIndex {
            let (length, matchLength, offset) = longestMatch(data, from: index)
            if matchLength == 0 {
                let next:C.Index = data.index(index, offsetBy: length)
                compressLiteral(data[index..<next], closure: closure)
                index = next
            } else {
                compressCopy(length: matchLength, offset: offset, closure: closure)
                index = data.index(index, offsetBy: matchLength)
            }
        }
        return nil
    }

    @inlinable
    func longestMatch<C: Collection<UInt8>>(_ data: C, from startIndex: C.Index) -> (length: Int, matchLength: Int, offset: Int) {
        let maxLength:Int = 60
        var longestMatchLength:Int = 0
        var offset:Int = 0

        var length:Int = 0
        var index:C.Index = startIndex
        while length < maxLength && index != data.endIndex {
            let starts:C.Index = data.index(index, offsetBy: -min(length, windowSize), limitedBy: data.startIndex) ?? data.startIndex
            let longestMatch:Int = longestCommonPrefix(data, index1: index, index2: starts)
            if length > longestMatchLength {
                longestMatchLength = longestMatch
                offset = data.distance(from: starts, to: index)
            }
            length += 1
            index = data.index(after: index)
        }
        return (length, longestMatchLength, offset: offset)
    }

    @inlinable
    func longestCommonPrefix<C: Collection<UInt8>>(_ data: C, index1: C.Index, index2: C.Index) -> Int {
        var length:Int = 0
        var index1:C.Index = index1
        var index2:C.Index = index2
        while index1 != data.endIndex && index2 != data.endIndex && data[index1] == data[index2] {
            length += 1
            index1 = data.index(after: index1)
            index2 = data.index(after: index2)
        }
        return length
    }
}

// MARK: Literal
extension CompressionTechnique.Snappy {
    @inlinable
    func compressLiteral<C: Collection<UInt8>>(_ data: C, closure: (UInt8) -> Void) {
        let count:Int = data.count
        if count < 60 {
            closure(UInt8(count << 2))
        } else {
            closure(UInt8(60 << 2))
            closure(UInt8(count))
        }
        for value in data {
            closure(value)
        }
    }
}

// MARK: Copy
extension CompressionTechnique.Snappy {
    @inlinable
    func compressCopy(length: Int, offset: Int, closure: (UInt8) -> Void) {
        if length < 12 && offset < 2048 {
            let cmd:UInt8 = UInt8((offset >> 8) << 5 | (length - 4) << 2 | 1)
            closure(cmd)
            closure(UInt8(offset & 0xFF))
        } else {
            closure(UInt8((length - 1) << 2) | 2)
            closure(UInt8(offset & 0xFF))
            closure(UInt8((offset >> 8) & 0xFF))
        }
    }
}*/

// MARK: Decompress
extension CompressionTechnique.Snappy {
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) {
        let totalSize:C.Index = data.index(data.startIndex, offsetBy: Int(data[data.startIndex]))
        var index:C.Index = data.index(after: data.startIndex)
        while index < totalSize {
            let control:UInt8 = data[index]
            switch control & 0b11 {
            case 0: decompressLiteral(flagBits: control, index: &index, compressed: data, closure: closure)
            case 1: decompressCopy1(flagBits: control, index: &index, compressed: data, closure: closure)
            case 2: decompressCopy2(flagBits: control.bitsTuple, index: &index, compressed: data, closure: closure)
            case 3: decompressCopy4(flagBits: control.bitsTuple, index: &index, compressed: data, closure: closure)
            default: break
            }
        }
    }
}

// MARK: Literal
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the length of the literal.
    @inlinable
    func decompressLiteral<C: Collection<UInt8>>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let length:Int = decompressLiteralLength(flagBits: flagBits, index: &index, compressed: compressed)
        for _ in 0...length {
            closure(compressed[index])
            compressed.formIndex(after: &index)
        }
    }

    /// - Complexity: O(1).
    @inlinable
    func decompressLiteralLength<C: Collection<UInt8>>(flagBits: UInt8, index: inout C.Index, compressed: C) -> Int {
        let length:UInt8 = flagBits >> 2 // ignore tag bits
        compressed.formIndex(after: &index)
        var totalLength:Int
        if length >= 60 {
            totalLength = 0
            for _ in 0..<length-59 {
                totalLength += Int(compressed[index])
                compressed.formIndex(after: &index)
            }
        } else {
            totalLength = Int(length)
        }
        return totalLength
    }
}

// MARK: Copy
extension CompressionTechnique.Snappy {
    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopy1<C: Collection<UInt8>>(
        flagBits: UInt8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        var length:UInt8 = 4 + ((flagBits >> 2) & 0b00000111)
        let offset:Int = Int(((UInt16(flagBits) << 8) & 0b11100000) + UInt16(compressed[compressed.index(index, offsetBy: 1)]))
        //let flagBits:Bits8 = flagBits.bitsTuple
        //var length:UInt8 = 4 + UInt8.init(fromBits: (flagBits.3, flagBits.4, flagBits.5))
        //let bits:Bits8 = compressed[compressed.index(index, offsetBy: 1)].bitsTuple
        //let offset:Int = Int(UInt16.init(fromBits: (flagBits.0, flagBits.1, flagBits.2, bits.0, bits.1, bits.2, bits.3, bits.4, bits.5, bits.6, bits.7)))
        //print("decompressCopy1;length=\(length);offset=\(offset);bitsTuple=\(flagBits.bitsTuple)")
        var begins:C.Index = compressed.index(index, offsetBy: -offset)
        while length != 0 {
            closure(compressed[begins])
            compressed.formIndex(after: &begins)
            length -= 1
        }
        compressed.formIndex(&index, offsetBy: 2)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopy2<C: Collection<UInt8>>(
        flagBits: Bits8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        //let offset:UInt16 = UInt16( UInt16(compressed[compressed.index(index, offsetBy: 1)]) << 8 | UInt16(compressed[compressed.index(index, offsetBy: 2)]) )
        let bits0:Bits8 = compressed[compressed.index(index, offsetBy: 1)].bitsTuple
        let bits1:Bits8 = compressed[compressed.index(index, offsetBy: 2)].bitsTuple
        let offset:UInt16 = UInt16(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 3, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopy4<C: Collection<UInt8>>(
        flagBits: Bits8,
        index: inout C.Index,
        compressed: C,
        closure: (_ byte: UInt8) -> Void
    ) {
        let bits0:Bits8 = compressed[compressed.index(index, offsetBy: 1)].bitsTuple
        let bits1:Bits8 = compressed[compressed.index(index, offsetBy: 2)].bitsTuple
        let bits2:Bits8 = compressed[compressed.index(index, offsetBy: 3)].bitsTuple
        let offset:UInt32 = UInt32(fromBits: (
            bits0.0, bits0.1, bits0.2, bits0.3, bits0.4, bits0.5, bits0.6, bits0.7,
            bits1.0, bits1.1, bits1.2, bits1.3, bits1.4, bits1.5, bits1.6, bits1.7,
            bits2.0, bits2.1, bits2.2, bits2.3, bits2.4, bits2.5, bits2.6, bits2.7
        ))
        decompressCopyN(flagBits: flagBits, index: &index, compressed: compressed, offset: offset, readBytes: 5, closure: closure)
    }

    /// - Complexity: O(_n_) where _n_ is the `UInt8` created from the `flagBits`.
    @inlinable
    func decompressCopyN<C: Collection<UInt8>, T: FixedWidthInteger>(
        flagBits: Bits8,
        index: inout C.Index,
        compressed: C,
        offset: T,
        readBytes: Int,
        closure: (_ byte: UInt8) -> Void
    ) {
        let length:UInt8 = UInt8(fromBits: (flagBits.0, flagBits.1, flagBits.2, flagBits.3, flagBits.4, flagBits.5))
        //print("decompressCopyN;readBytes=\(readBytes);length=\(length)")
        var begins:C.Index = compressed.index(index, offsetBy: -Int(offset))
        for _ in 0..<length {
            closure(compressed[begins])
            compressed.formIndex(after: &begins)
        }
        compressed.formIndex(&index, offsetBy: readBytes)
    }
}