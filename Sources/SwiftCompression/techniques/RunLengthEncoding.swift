
import SwiftCompressionUtilities

extension CompressionTechnique {

    /// The Run-length encoding compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Run-length_encoding
    public static func runLength(minRun: Int, alwaysIncludeRunCount: Bool) -> RunLengthEncoding {
        return RunLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
    }

    public struct RunLengthEncoding: Compressor, Decompressor {
        public typealias CompressClosureParameters = (run: Int, byte: UInt8)

        /// Minimum run count required to compress identical sequential bytes.
        public let minRun:Int

        /// Whether or not to always include the run count in the result, regardless of run count.
        public let alwaysIncludeRunCount:Bool

        public init(minRun: Int, alwaysIncludeRunCount: Bool) {
            self.minRun = minRun
            self.alwaysIncludeRunCount = alwaysIncludeRunCount
        }

        @inlinable
        public var algorithm: CompressionAlgorithm {
            .runLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        }

        @inlinable
        public var quality: CompressionQuality {
            .lossless
        }
    }
}

// MARK: Compress
extension CompressionTechnique.RunLengthEncoding {
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
    ///   - data: Sequence of bytes to compress.
    ///   - minRun: Minimum run count required to compress identical sequential bytes.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(data: some Sequence<UInt8>, closure: (CompressClosureParameters) -> Void) -> UInt8? {
        var run = 0
        var runByte:UInt8? = nil
        data.withContiguousStorageIfAvailable { p in
            for index in 0..<p.count {
                let byte = p[index]
                if runByte == byte {
                    if run == 64 {
                        closure((run, runByte!))
                        run = 1
                    } else {
                        run += 1
                    }
                } else {
                    if let runByte {
                        closure((run, runByte))
                    }
                    runByte = byte
                    run = 1
                }
            }
        }
        if let runByte {
            closure((run, runByte))
        }
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.RunLengthEncoding {
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(data: some Collection<UInt8>, closure: (UInt8) -> Void) {
        let count = data.count
        var index = 0
        var run:UInt8 = 0
        var character:UInt8 = 0
        while index < count {
            run = data[index]
            if run > 191 {
                run -= 191
                character = data[index+1]
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