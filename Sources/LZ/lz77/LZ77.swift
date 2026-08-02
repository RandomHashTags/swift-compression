
import SwiftCompressionUtilities

/// The LZ77 compression technique.
/// 
/// - Generics:
///   - T: Integer type the offset is encoded as.
/// 
/// https://en.wikipedia.org/wiki/LZ77_and_LZ78
public struct LZ77<T: FixedWidthInteger & Sendable>: Sendable {
    /// Size of the search buffer.
    public let searchBufferSize:Int

    /// Size of the lookahead buffer.
    public let lookaheadBufferSize:Int

    /// - Parameters:
    ///   - windowSize: Size of the sliding window, measured in bytes.
    ///   - bufferSize: Size of the buffer, measured in bytes.
    public init(searchBufferSize: Int, lookaheadBufferSize: Int) {
        self.searchBufferSize = searchBufferSize
        self.lookaheadBufferSize = lookaheadBufferSize
    }

    public var algorithm: CompressionAlgorithm {
        .lz77(windowSize: searchBufferSize, bufferSize: lookaheadBufferSize, offsetBitWidth: T.bitWidth)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}