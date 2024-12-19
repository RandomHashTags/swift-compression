//
//  DNAC-SBE.swift
//
//
//  Created by Evan Anderson on 12/18/24.
//

public extension CompressionTechnique {
    /// The DNAC-SBE compression technique.
    /// 
    /// https://www.mdpi.com/1999-4893/13/4/99
    enum DNAC_SBE {
    }
}

// MARK: Compress
public extension CompressionTechnique.DNAC_SBE {
    /// Compress a sequence of bytes using the DNAC-SBE technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    /// - Complexity: O(_n_ * 2 + (_m_ log _m_)) where _n_ is the length of `data` and _m_ is the number of unique bytes in `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S
    ) -> CompressionResult<[UInt8]>? { // TODO: finish
        let frequencyTable:[UInt8:Int] = CompressionTechnique.buildFrequencyTable(data: data)
        var sortedFrequencyTable:[[UInt8:Int].Element] = frequencyTable.sorted(by: {
            guard $0.value != $1.value else { return $0.key < $1.key }
            return $0.value > $1.value
        })
        sortedFrequencyTable.removeLast()
        var sortedIndexes:[UInt8:Int] = [:], results:[UInt8:[UInt8]] = [:]
        for (index, (key, _)) in sortedFrequencyTable.enumerated() {
            results[key] = []
            sortedIndexes[key] = index
        }
        for byte in data {
            let sortedIndex:Int = sortedIndexes[byte] ?? sortedIndexes.count
            for i in 0..<sortedIndex {
                results[sortedFrequencyTable[i].key]!.append(0)
            }
            results[byte]?.append(1)
        }
        /*for (base, _) in sortedFrequencyTable {
            print("base=\(Character(Unicode.Scalar(base)));result=\(results[base]!.debugDescription)")
        }*/
        return nil
    }
}

// MARK: Decompress
public extension CompressionTechnique.DNAC_SBE { // TODO: finish
    /// Decompress a sequence of bytes using the DNAC-SBE technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        return []
    }
}