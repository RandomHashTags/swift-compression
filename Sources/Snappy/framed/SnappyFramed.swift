
import SwiftCompressionUtilities

/// The Snappy Framed compression technique.
/// 
/// https://en.wikipedia.org/wiki/Snappy_(compression)#Framing_format
/// 
/// https://github.com/google/snappy
struct SnappyFramed: Sendable {        
    public var algorithm: CompressionAlgorithm {
        .snappyFramed
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}