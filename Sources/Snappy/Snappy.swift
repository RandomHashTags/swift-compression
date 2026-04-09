
import SwiftCompressionUtilities

/// The Snappy (Zippy) compression technique.
/// 
/// https://en.wikipedia.org/wiki/Snappy_(compression)
/// 
/// https://github.com/google/snappy
public struct Snappy: Sendable {

    public init() {
    }

    public var algorithm: CompressionAlgorithm {
        .snappy
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}