//
//  RunLengthEncoding.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

public extension CompressionTechnique {

    /// The Run-length encoding compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Run-length_encoding
    @inlinable
    static func runLength(minRun: Int, alwaysIncludeRunCount: Bool) -> RunLengthEncoding {
        return RunLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
    }

    struct RunLengthEncoding : Compressor {
        public typealias CompressClosureParameters = (run: Int, byte: UInt8)
        public typealias DecompressClosureParameters = UInt8

        /// The minimum run count required to compress identical sequential bytes.
        public let minRun:Int

        /// Whether or not to always include the run count in the result, regardless of run count.
        public let alwaysIncludeRunCount:Bool

        public init(minRun: Int, alwaysIncludeRunCount: Bool) {
            self.minRun = minRun
            self.alwaysIncludeRunCount = alwaysIncludeRunCount
        }

        public var rawValue : String { "runLength" }
    }
}

// MARK: Compress
public extension CompressionTechnique.RunLengthEncoding {
    /// Compress a sequence of bytes using the Run-length encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - reserveCapacity: Reserves enough space to store the specified number of elements.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress<S: Sequence<UInt8>>(
        data: S,
        reserveCapacity: Int = 1024
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
        compress(data: data, closure: closure)
        return compressed
    }

    /// Compress a sequence of bytes using the Run-length encoding technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: 
    ///   - alwaysIncludeRunCount: 
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress<S: Sequence<UInt8>>(
        data: S,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
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
        compress(data: data, closure: closure)
    }

    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress<S: Sequence<UInt8>>(data: S, closure: (CompressClosureParameters) -> Void) -> UInt8? {
        var run:Int = 0, runByte:UInt8? = nil
        data.withContiguousStorageIfAvailable { p in
            for index in 0..<p.count {
                let byte:UInt8 = p[index]
                if runByte == byte {
                    if run == 64 {
                        closure((run, runByte!))
                        run = 1
                    } else {
                        run += 1
                    }
                } else {
                    if let runByte:UInt8 = runByte {
                        closure((run, runByte))
                    }
                    runByte = byte
                    run = 1
                }
            }
        }
        if let runByte:UInt8 = runByte {
            closure((run, runByte))
        }
        return nil
    }
}

// MARK: Decompress
public extension CompressionTechnique.RunLengthEncoding {
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func decompress<C: Collection<UInt8>>(data: C, closure: (DecompressClosureParameters) -> Void) {
        let count:Int = data.count
        var index:Int = 0, run:UInt8 = 0, character:UInt8 = 0
        while index < count {
            run = data[data.index(data.startIndex, offsetBy: index)]
            if run > 191 {
                run -= 191
                character = data[data.index(data.startIndex, offsetBy: index+1)]
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