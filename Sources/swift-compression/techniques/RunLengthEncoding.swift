//
//  RunLengthEncoding.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

extension CompressionTechnique {

    /// The Run-length encoding compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Run-length_encoding
    @inlinable
    public static func runLength(minRun: Int, alwaysIncludeRunCount: Bool) -> RunLengthEncoding {
        return RunLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
    }

    public struct RunLengthEncoding : Compressor, Decompressor {
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

        @inlinable public var algorithm : CompressionAlgorithm { .runLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount) }
        @inlinable public var quality : CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.RunLengthEncoding {
    @inlinable
    public func compressClosure(closure: @escaping (UInt8) -> Void) -> @Sendable (CompressClosureParameters) -> Void {
        if alwaysIncludeRunCount {
            return { (arg) in
                let (run, runByte) = arg
                closure(UInt8(191 + run))
                closure(runByte)
            }
        } else {
            return { (arg) in
                let (run, runByte) = arg
                if runByte <= 191 && run < minRun {
                    for byte in Array(repeating: runByte, count: run) {
                        closure(byte)
                    }
                } else {
                    closure(UInt8(191 + run))
                    closure(runByte)
                }
            }
        }
    }

    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<S: Sequence<UInt8>>(data: S, closure: (CompressClosureParameters) -> Void) -> UInt8? {
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
extension CompressionTechnique.RunLengthEncoding {
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<C: Collection<UInt8>>(data: C, closure: (DecompressClosureParameters) -> Void) {
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