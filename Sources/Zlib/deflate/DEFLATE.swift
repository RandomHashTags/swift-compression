
import SwiftCompressionUtilities
import ZlibShim

// https://en.wikipedia.org/wiki/Gzip
// https://www.rfc-editor.org/rfc/rfc1952#page-5

/// The Deflate compression technique.
/// 
/// https://en.wikipedia.org/wiki/Deflate
public struct Deflate: Sendable {
    public let bufferSize:Int
    public let level:Int32

    public init(
        bufferSize: Int = 1024,
        level: Int32 = Z_DEFAULT_COMPRESSION
    ) {
        self.bufferSize = bufferSize
        self.level = level
    }

    public var algorithm: CompressionAlgorithm {
        .deflate
    }

    public var quality: CompressionQuality {
        .lossless
    }
}