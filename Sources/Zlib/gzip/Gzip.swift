
#if ZlibGzip

import SwiftCompressionUtilities
import ZlibShim

// https://www.rfc-editor.org/rfc/rfc1952

/// The Gzip compression technique.
/// 
/// https://en.wikipedia.org/wiki/Gzip
public struct Gzip: Sendable {
    public let bufferSize:Int
    public let level:Int32
    public let memLevel:Int32
    public let strategy:Int32

    public init(
        bufferSize: Int = 1024,
        level: Int32 = Z_DEFAULT_COMPRESSION,
        memLevel: Int32 = 8,
        strategy: Int32 = Z_DEFAULT_STRATEGY
    ) {
        self.bufferSize = bufferSize
        self.level = level
        self.memLevel = memLevel
        self.strategy = strategy
    }

    public var algorithm: CompressionAlgorithm {
        .gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}

#endif