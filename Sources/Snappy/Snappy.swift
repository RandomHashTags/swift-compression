
import SwiftCompressionUtilities

public struct Snappy: Sendable {

    /// Size of the window.
    public let windowSize:Int

    public init(windowSize: Int = Int(UInt16.max)) {
        self.windowSize = windowSize
    }

    public var algorithm: CompressionAlgorithm {
        .snappy(windowSize: windowSize)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}

extension CompressionTechnique {
    /// The Snappy (Zippy) compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)
    /// 
    /// https://github.com/google/snappy
    public static func snappy(windowSize: Int = Int(UInt16.max)) -> Snappy {
        return Snappy(windowSize: windowSize)
    }
}