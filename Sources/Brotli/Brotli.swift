
#if Brotli

import BrotliShim
import SwiftCompressionUtilities

/// The Brotli compression technique.
/// 
/// https://github.com/google/brotli
/// 
/// https://en.wikipedia.org/wiki/Brotli
public struct Brotli: Sendable {
    public let quality:Int32

    /// Size of the window.
    public let windowSize:Int32

    public let mode:UInt32

    public init(
        quality: Int32 = BROTLI_DEFAULT_QUALITY,
        windowSize: Int32 = BROTLI_DEFAULT_WINDOW,
        mode: UInt32 = BROTLI_MODE_GENERIC.rawValue
    ) {
        self.quality = quality
        self.windowSize = windowSize
        self.mode = mode
    }

    public var algorithm: CompressionAlgorithm {
        .brotli(quality: quality, windowSize: windowSize, mode: mode)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}

#endif