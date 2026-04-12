
import SwiftCompressionUtilities

/// The Run-length encoding compression technique.
/// 
/// https://en.wikipedia.org/wiki/Run-length_encoding
public struct RunLengthEncoding: Sendable {
    public typealias CompressClosureParameters = (run: Int, byte: UInt8)

    /// Minimum run count required to compress identical sequential bytes.
    public let minRun:Int

    /// Whether or not to always include the run count in the result, regardless of run count.
    public let alwaysIncludeRunCount:Bool

    public init(minRun: Int, alwaysIncludeRunCount: Bool) {
        self.minRun = minRun
        self.alwaysIncludeRunCount = alwaysIncludeRunCount
    }

    public var algorithm: CompressionAlgorithm {
        .runLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}