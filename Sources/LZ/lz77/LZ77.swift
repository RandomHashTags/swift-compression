
import SwiftCompressionUtilities

public struct LZ77<T: FixedWidthInteger & Sendable>: Sendable {
    /// Size of the window.
    public let windowSize:Int

    /// Size of the buffer.
    public let bufferSize:Int

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

extension CompressionTechnique {
    /// The LZ77 compression technique.
    /// 
    /// - Parameters:
    ///   - T: Integer type the offset is encoded as. Default is `UInt16`.
    ///   - windowSize: Size of the sliding window, measured in bytes.
    ///   - bufferSize: Size of the buffer, measured in bytes.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    public static func lz77<T: FixedWidthInteger & Sendable>(windowSize: Int, bufferSize: Int) -> LZ77<T> {
        return LZ77(windowSize: windowSize, bufferSize: bufferSize)
    }

    /// The LZ77 compression technique where the offset is encoded as a `UInt16`.
    /// 
    /// - Parameters:
    ///   - windowSize: Size of the sliding window, measured in bytes.
    ///   - bufferSize: Size of the buffer, measured in bytes.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    public static func lz77(windowSize: Int, bufferSize: Int) -> LZ77<UInt16> {
        return LZ77(windowSize: windowSize, bufferSize: bufferSize)
    }
}