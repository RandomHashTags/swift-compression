//
//  RunLengthEncoding.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

// https://en.wikipedia.org/wiki/Run-length_encoding
public extension CompressionTechnique {
    enum RunLengthEncoding {
    }
}

// MARK: Compress Data
public extension CompressionTechnique.RunLengthEncoding {
    @inlinable
    static func compress(minRun: Int, includeCountForMinRun: Bool = true, data: Data) -> CompressionResult {
        let closure:(inout Data, Int, UInt8) -> Void
        if includeCountForMinRun {
            closure = { compressed, run, runByte in
                compressed.append(UInt8(191 + run))
                compressed.append(runByte)
            }
        } else {
            closure = { compressed, run, runByte in
                if runByte <= 191 && run < minRun {
                    compressed.append(contentsOf: Array(repeating: runByte, count: run))
                } else {
                    compressed.append(UInt8(191 + run))
                    compressed.append(runByte)
                }
            }
        }
        return compress(minRun: minRun, data: data, closure: closure)
    }
    static func compress(minRun: Int, data: Data, closure: (inout Data, Int, UInt8) -> Void) -> CompressionResult {
        var compressed:Data = Data()
        compressed.reserveCapacity(data.count)
        var run:Int = 0, runByte:UInt8 = data[0]
        data.withUnsafeBytes { p in
            for index in 0..<p.count {
                let byte:UInt8 = p[index]
                if runByte == byte {
                    if run == 64 {
                        closure(&compressed, run, runByte)
                        run = 1
                    } else {
                        run += 1
                    }
                } else {
                    closure(&compressed, run, runByte)
                    runByte = byte
                    run = 1
                }
            }
        }
        closure(&compressed, run, runByte)
        return CompressionResult(data: compressed)
    }
}

// MARK: Decompress Data
public extension CompressionTechnique.RunLengthEncoding {
    @inlinable
    static func decompress(data: Data) -> Data {
        var decompressed:Data = Data()
        data.withUnsafeBytes { p in
            var index:Int = 0, run:UInt8 = 0, character:UInt8 = 0
            while index < p.count {
                run = p[index]
                if run > 191 {
                    run -= 191
                    character = p[index+1]
                    index += 2
                } else {
                    character = run
                    run = 1
                    index += 1
                }
                decompressed.append(contentsOf: Array(repeating: character, count: Int(run)))
            }
        }
        return decompressed
    }
}