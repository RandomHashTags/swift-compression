//
//  RunLengthEncoding.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

#if canImport(Foundation)
import Foundation
#endif

public extension CompressionTechnique {
    /// The Run-length encoding compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Run-length_encoding
    enum RunLengthEncoding {
    }
}

// MARK: Compress
public extension CompressionTechnique.RunLengthEncoding {
    /// Compress a sequence of bytes using the Run-length encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - reserveCapacity: Reserves enough space to store the specified number of elements.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: Whether or not to always include the run count in the result, regardless of run count.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S,
        reserveCapacity: Int = 1024,
        minRun: Int,
        alwaysIncludeRunCount: Bool
    ) -> [UInt8] {
        let closure:(Int, UInt8) -> Void
        var compressed:[UInt8] = []
        compressed.reserveCapacity(reserveCapacity)
        if alwaysIncludeRunCount {
            closure = { run, runByte in
                compressed.append(UInt8(191 + run))
                compressed.append(runByte)
            }
        } else {
            closure = { run, runByte in
                if runByte <= 191 && run < minRun {
                    compressed.append(contentsOf: Array(repeating: runByte, count: run))
                } else {
                    compressed.append(UInt8(191 + run))
                    compressed.append(runByte)
                }
            }
        }
        compress(data: data, minRun: minRun, closure: closure)
        return compressed
    }

    /// Compress a sequence of bytes using the Run-length encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: Whether or not to always include the run count in the result, regardless of run count.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(
        data: S,
        minRun: Int,
        alwaysIncludeRunCount: Bool,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            let closure:(Int, UInt8) -> Void
            if alwaysIncludeRunCount {
                closure = { run, runByte in
                    continuation.yield(UInt8(191 + run))
                    continuation.yield(runByte)
                }
            } else {
                closure = { run, runByte in
                    if runByte <= 191 && run < minRun {
                        for _ in 0..<run {
                            continuation.yield(runByte)
                        } 
                    } else {
                        continuation.yield(UInt8(191 + run))
                        continuation.yield(runByte)
                    }
                }
            }
            compress(data: data, minRun: minRun, closure: closure)
            continuation.finish()
        }
    }

    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<S: Sequence<UInt8>>(data: S, minRun: Int, closure: (_ run: Int, _ runByte: UInt8) -> Void) {
        var run:Int = 0, runByte:UInt8? = nil
        data.withContiguousStorageIfAvailable { p in
            for index in 0..<p.count {
                let byte:UInt8 = p[index]
                if runByte == byte {
                    if run == 64 {
                        closure(run, runByte!)
                        run = 1
                    } else {
                        run += 1
                    }
                } else {
                    if let runByte:UInt8 = runByte {
                        closure(run, runByte)
                    }
                    runByte = byte
                    run = 1
                }
            }
        }
        if let runByte:UInt8 = runByte {
            closure(run, runByte)
        }
    }
}

// MARK: Decompress
public extension CompressionTechnique.RunLengthEncoding {
    /// Decompress a sequence of bytes using the Run-length encoding compression technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompress(data: data) { decompressed.append($0) }
        return decompressed
    }

    /// Decompress a sequence of bytes into a stream using the Run-length encoding compression technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress(
        data: [UInt8],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return AsyncStream(bufferingPolicy: limit) { continuation in
            decompress(data: data) { continuation.yield($0) }
            continuation.finish()
        }
    }

    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress(data: [UInt8], closure: (_ byte: UInt8) -> Void) {
        data.withUnsafeBytes { p in
            var index:Int = 0, run:UInt8 = 0, character:UInt8 = 0
            while index < p.count {
                run = p[index]
                if run > 191 {
                    run -= 191
                    character = p[index+1]
                    index += 2
                    for _ in 0..<run {
                        closure(character)
                    }
                } else {
                    index += 1
                    closure(run)
                }
            }
        }
    }
}