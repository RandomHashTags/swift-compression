
import SwiftCompressionUtilities

/// The LZ77 compression technique.
/// 
/// - Generics:
///   - T: Integer type the offset is encoded as.
/// 
/// https://en.wikipedia.org/wiki/LZ77_and_LZ78
public struct LZ77<T: FixedWidthInteger & Sendable>: Sendable {
    /// Size of the window.
    public let windowSize:Int

    /// Size of the buffer.
    public let bufferSize:Int

    /// - Parameters:
    ///   - windowSize: Size of the sliding window, measured in bytes.
    ///   - bufferSize: Size of the buffer, measured in bytes.
    public init(windowSize: Int, bufferSize: Int) {
        self.windowSize = windowSize
        self.bufferSize = bufferSize
    }

    public var algorithm: CompressionAlgorithm {
        .lz77(windowSize: windowSize, bufferSize: bufferSize, offsetBitWidth: T.bitWidth)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}