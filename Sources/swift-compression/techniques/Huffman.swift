//
//  Huffman.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public extension CompressionTechnique {
    enum Huffman { // TODO: finish
    }
}


// MARK: Compress Data
public extension CompressionTechnique.Huffman {
    @inlinable
    static func compress(data: [UInt8]) -> CompressionResult<[UInt8]> {
        var priorities:[Int:Int] = Dictionary(minimumCapacity: 255)
        for i in 0..<data.count {
            let char:UInt8 = data[i]
            if priorities[Int(char)] == nil {
                priorities[Int(char)] = 1
            } else {
                priorities[Int(char)]! += 1
            }
        }
        let sorted:[Dictionary<Int, Int>.Element] = priorities.sorted(by: { $0.value >= $1.value })
        var compressed:[UInt8] = []
        compressed.reserveCapacity(data.count)
        var alignment:Int = 0
        for (char, freq) in sorted {
            print("Huffman;compress;priority for char \(Character(Unicode.Scalar(char)!))=\(freq)")
        }
        if alignment != 0 {
        }
        return CompressionResult(data: compressed, frequencyTable: nil)
    }
}

// MARK: Decompress Data
extension CompressionTechnique.Huffman {
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        return data
    }
}