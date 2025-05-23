//
//  DNASingleBlockEncoding.swift
//
//
//  Created by Evan Anderson on 12/18/24.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The DNA single block encoding compression technique.
    /// 
    /// https://www.mdpi.com/1999-4893/13/4/99
    public static let dnaSingleBlockEncoding:DNASingleBlockEncoding = DNASingleBlockEncoding()

    public struct DNASingleBlockEncoding : Compressor, Decompressor {
        @inlinable public var algorithm : CompressionAlgorithm { .dnaSingleBlockEncoding }
        @inlinable public var quality : CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.DNASingleBlockEncoding {
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) throws(CompressionError) -> UInt8? { // TODO: fix
        return nil
    }

    /// Compress a sequence of bytes using the DNA single block encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_ + (_m_ log _m_)) where _n_ is the length of `data` and _m_ is the number of unique bytes in `data`.
    @inlinable
    public static func compress<S: Collection<UInt8>>(
        data: S,
        reserveCapacity: Int
    ) -> CompressionResult<[UInt8]>? { // TODO: finish
        let results = compressBinary(data: data)
        for (base, _) in results {
            print("base=\(Character(Unicode.Scalar(base)));result=\(results[base]!.debugDescription)")
        }
        return nil
    }
}

extension CompressionTechnique.DNASingleBlockEncoding {
    /// Compress a sequence of bytes using phase one (compress data to binary) of the DNA single block encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_ + (_m_ log _m_)) where _n_ is the length of `data` and _m_ is the number of unique bytes in `data`.
    @inlinable
    static func compressBinary<S: Sequence<UInt8>>(
        data: S
    ) -> [UInt8:[UInt8]] {
        let frequencyTable:[UInt8:Int] = CompressionTechnique.buildFrequencyTable(data: data)
        var sortedFrequencyTable = frequencyTable.sorted(by: {
            guard $0.value != $1.value else { return $0.key < $1.key }
            return $0.value > $1.value
        })
        sortedFrequencyTable.removeLast()
        var sortedIndexes:[UInt8:Int] = [:]
        var results:[UInt8:[UInt8]] = [:]
        for (index, (key, _)) in sortedFrequencyTable.enumerated() {
            results[key] = []
            sortedIndexes[key] = index
        }
        for byte in data {
            let sortedIndex = sortedIndexes[byte] ?? sortedIndexes.count
            for i in 0..<sortedIndex {
                results[sortedFrequencyTable[i].key]!.append(0)
            }
            results[byte]?.append(1)
        }
        return results
    }
}

extension CompressionTechnique.DNASingleBlockEncoding {
    /// Compress a collection of bits using phase two (compress bits to bit blocks) of the DNA single block encoding technique.
    /// 
    /// https://www.mdpi.com/algorithms/algorithms-13-00099/article_deploy/html/images/algorithms-13-00099-g002.png
    /// https://www.mdpi.com/algorithms/algorithms-13-00099/article_deploy/html/images/algorithms-13-00099-g003.png
    /// 
    /// - Parameters:
    ///   - binaryData: Collection of bits to compress.
    /// - Returns: Compressed bit blocks and the control bits.
    /// - Complexity: O(_n_) where _n_ is the length of `binaryData`.
    @inlinable
    static func compressSBE<C: Collection<UInt8>>(
        binaryData: C
    ) -> (data: [UInt8], controlBits: [UInt8]) {
        var compressed:[UInt8] = []
        var controlBits:[UInt8] = []

        var previousBits:[UInt8] = []
        previousBits.reserveCapacity(6)
        var positionBlock:[UInt8] = []
        positionBlock.reserveCapacity(6)

        var index = 0
        var bitIndex = 0
        var controlBit:UInt8 = 0
        while index < binaryData.count {
            let bit = binaryData[index]
            switch bitIndex {
            case 0:
                controlBit = bit
                controlBits.append(bit)
            default:
                if let previousBit = previousBits.get(bitIndex-1) {
                    if bitIndex == 1 && previousBit == 1 {
                        positionBlock.append(0)
                    } else {
                        positionBlock.append(bit != previousBit ? 1 : 0)
                    }
                } else {
                    positionBlock.append(0)
                }
                previousBits.append(bit)
            }
            index += 1
            bitIndex += 1
            if bitIndex == 7 {
                compressed.append(controlBit)
                var code0:[UInt8] = []
                var code1:[UInt8] = []
                var found0 = false
                var found1 = false
                for bit in positionBlock {
                    if bit == 0 || found0 {
                        found0 = true
                        code0.append(bit)
                        if found1 {
                            found1 = false
                            code1.append(0)
                        }
                    }
                    if bit == 1 {
                        if !found0 {
                            code0.append(1)
                        }
                        found1 = true
                        code1.append(bit)
                    }
                }
                //print("positionBlock=\(positionBlock)\ncode0=\(code0)\ncode1=\(code1)")
                compressed.append(contentsOf: code0.count < code1.count ? code0 : code1)
                bitIndex = 0
                previousBits.removeAll(keepingCapacity: true)
                positionBlock.removeAll(keepingCapacity: true)
            }
        }
        return (compressed, controlBits)
    }
}

// MARK: Decompress
extension CompressionTechnique.DNASingleBlockEncoding { // TODO: finish
    @inlinable
    public func decompress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) throws(DecompressionError) {
    }

    /// Decompress a sequence of bytes using the DNA single block encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    @inlinable
    public static func decompress(data: [UInt8]) -> [UInt8] {
        return []
    }
}