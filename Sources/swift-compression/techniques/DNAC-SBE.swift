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
    @inlinable
    static func compress<S: Sequence<UInt8>>( // TODO: finish
        data: S
    ) -> CompressionResult<[UInt8]>? {
        let frequencyTable:[UInt8:Int] = CompressionTechnique.buildFrequencyTable(data: data)
        var sortedFrequencyTable:[[UInt8:Int].Element] = frequencyTable.sorted(by: {
            guard $0.value != $1.value else { return $0.key < $1.key }
            return $0.value > $1.value
        })
        let (last, lastFrequency):(UInt8, Int) = sortedFrequencyTable.removeLast()
        var results:[UInt8:[UInt8]] = [:]
        for (key, _) in sortedFrequencyTable {
            results[key] = []
        }
        let first:UInt8 = sortedFrequencyTable[0].key
        for (base, _) in sortedFrequencyTable {
            for byte in data {
                if base == byte {
                    results[byte]!.append(1)
                } else if (frequencyTable[base] ?? 0) > (frequencyTable[byte] ?? 0) {
                    results[base]?.append(0)
                }
            }
            if base != first {
                while results[base]?.first == 0 {
                    results[base]!.removeFirst()
                }
            }
            //print("base=\(Character(Unicode.Scalar(base)));result=\(results[base]?.debugDescription)")
        }
        return nil
    }
}

// MARK: Decompress
public extension CompressionTechnique.DNAC_SBE { // TODO: finish
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        return []
    }
}