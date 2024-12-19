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
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - reserveCapacity: Reserves enough space to store the specified number of elements.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: Whether or not to always include the run count in the result, regardless of run count.
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
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: Whether or not to always include the run count in the result, regardless of run count.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
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

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compresses this data using the Run-length encoding technique.
    /// - Parameters:
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: whether or not to always include the count of a byte, regardless of run count.
    /// - Returns: `self`.
    @discardableResult
    @inlinable
    mutating func compressRLE(minRun: Int = 3, alwaysIncludeRunCount: Bool = false) -> Self {
        self = CompressionTechnique.RunLengthEncoding.compress(data: self, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        return self
    }

    /// Compress a copy of this data using the Run-length encoding technique.
    /// - Parameters:
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: whether or not to always include the number of repeated bytes, regardless of run count.
    /// - Returns: The compressed data.
    @inlinable
    func compressedRLE(minRun: Int = 3, alwaysIncludeRunCount: Bool = false) -> [UInt8] {
        return CompressionTechnique.RunLengthEncoding.compress(data: self, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Compress this data to a stream using the Run-length encoding technique.
    /// - Parameters:
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: whether or not to always include the number of repeated bytes, regardless of run count.
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that compresses the data.
    @inlinable
    func compressRLE(
        minRun: Int = 3,
        alwaysIncludeRunCount: Bool = false,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.RunLengthEncoding.compress(data: self, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount, bufferingPolicy: limit)
    }
}

#if canImport(Foundation)
public extension Data {
    /// Compress this data into a stream using the Run-length encoding technique.
    /// - Parameters:
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - alwaysIncludeRunCount: whether or not to always include the number of repeated bytes, regardless of run count.
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that compresses the data.
    @inlinable
    func compressRLE(
        minRun: Int = 3,
        alwaysIncludeRunCount: Bool = false,
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.RunLengthEncoding.compress(data: [UInt8](self), minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount, bufferingPolicy: limit)
    }
}
#endif

// MARK: Decompress
public extension CompressionTechnique.RunLengthEncoding {
    /// Decompress a sequence of bytes using the Run-length encoding compression technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompress(data: data) { decompressed.append($0) }
        return decompressed
    }

    /// Decompress a sequence of bytes into a stream using the Run-length encoding compression technique.
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
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

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compresses this data using the Run-length encoding technique.
    /// - Returns: `self`.
    @discardableResult
    @inlinable
    mutating func decompressRLE() -> Self {
        self = CompressionTechnique.RunLengthEncoding.decompress(data: self)
        return self
    }

    /// Compress a copy of this data using the Run-length encoding technique.
    /// - Returns: The compressed data.
    @inlinable
    func decompressedRLE() -> [UInt8] {
        return CompressionTechnique.RunLengthEncoding.decompress(data: self)
    }
}

// MARK: AsyncStream
public extension Array where Element == UInt8 {
    /// Compress this data to a stream using the Run-length encoding technique.
    /// - Parameters:
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that decompresses the data.
    @inlinable
    func decompressRLE(
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.RunLengthEncoding.decompress(data: self, bufferingPolicy: limit)
    }
}

#if canImport(Foundation)
public extension Data {
    /// Compress this data into a stream using the Run-length encoding technique.
    /// - Parameters:
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers an unlimited number of elements. You can also set the policy to buffer a specified number of oldest or newest elements.
    /// - Returns: An `AsyncStream<UInt8>` that compresses the data.
    @inlinable
    func decompressRLE(
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        return CompressionTechnique.RunLengthEncoding.decompress(data: [UInt8](self), bufferingPolicy: limit)
    }
}
#endif