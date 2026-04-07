
import SwiftCompressionUtilities

public struct Brotli: Sendable { // TODO: finish
    /// Size of the window.
    public let windowSize:Int

    /// Predefined dictionary to use.
    //public let dictionary:[String:String]

    public init(windowSize: Int = 32768) {
        self.windowSize = windowSize
    }

    public var algorithm: CompressionAlgorithm {
        .brotli(windowSize: windowSize)
    }

    public var quality: CompressionQuality {
        .lossless
    }
}

extension CompressionTechnique {
    /// The Brotli compression technique.
    /// 
    /// https://github.com/google/brotli
    /// 
    /// https://en.wikipedia.org/wiki/Brotli
    public static func brotli(windowSize: Int = 32768) -> Brotli {
        return Brotli(windowSize: windowSize)
    }
}