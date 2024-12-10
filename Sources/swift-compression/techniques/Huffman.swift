//
//  Huffman.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

enum Huffman { // TODO: finish
}

// MARK: Compress Data
extension Huffman {
    static func compress(data: Data) -> CompressionResult {
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
        var compressed:Data = Data()
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
extension Huffman {
    static func decompress(data: Data) -> Data {
        return data
    }
}

extension Huffman {
    struct DataBuilder {
        var data:Data = Data()
        var bitBuilder:IntBitBuilder = IntBitBuilder()

        mutating func write(bits: [Bool]) {
            bitBuilder.write(bits: bits, to: &data)
        }
        mutating func finalize() {
            bitBuilder.flush(into: &data)
        }
    }
    struct IntBitBuilder {
        var bits:[Bool] = Array(repeating: false, count: 8)
        var index:Int = 0

        mutating func write(bits: [Bool], to data: inout Data) {
            var wrote:Int = 0
            while wrote != bits.count {
                let available_bits:Int = min(8 - index, max(0, bits.count - wrote))
                if available_bits > 0 {
                    for i in 0..<available_bits {
                        self.bits[index + i] = bits[wrote + i]
                    }
                    index += available_bits
                    if index == 8 {
                        data.append(UInt8(fromBits: self.bits)!)
                        index = 0
                    }
                }
                wrote += available_bits
            }
        }
        mutating func flush(into data: inout Data) {
            if index != 8 {
                while index != 8 {
                    bits[index] = false
                    index += 1
                }
                data.append(UInt8(fromBits: bits)!)
            }
        }
    }
}