
#if RunLengthEncodingCompress

import SwiftCompressionUtilities

extension RunLengthEncoding: Compressor {
    public typealias ConcreteCompressionConfiguration = CompressConfiguration
    public typealias ConcreteCompressionResult = [UInt8]

    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: CompressConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        span.withUnsafeBufferPointer {
            compress(buffer: $0, closure: compressClosure(closure: { result.append($0) }))
        }
        return result
    }
}

extension RunLengthEncoding {
    func compressClosure(closure: @escaping (UInt8) -> Void) -> (CompressClosureParameters) -> Void {
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
    func compress(
        buffer: UnsafeBufferPointer<UInt8>,
        closure: (CompressClosureParameters) -> Void
    ) {
        var run = 0
        var runByte:UInt8? = nil
        for index in 0..<buffer.count {
            let byte = buffer[index]
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
        if let runByte {
            closure((run, runByte))
        }
    }
}

// MARK: Configuration
extension RunLengthEncoding {
    public struct CompressConfiguration: CompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}

#endif