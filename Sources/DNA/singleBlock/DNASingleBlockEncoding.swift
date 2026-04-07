
import SwiftCompressionUtilities

/// The DNA single block encoding compression technique.
/// 
/// https://www.mdpi.com/1999-4893/13/4/99
public struct DNASingleBlockEncoding: Sendable {
    public var algorithm: CompressionAlgorithm {
        .dnaSingleBlockEncoding
    }

    public var quality: CompressionQuality {
        .lossless
    }

    public init() {
    }
}

extension CompressionTechnique {
    /// The DNA single block encoding compression technique.
    /// 
    /// https://www.mdpi.com/1999-4893/13/4/99
    public static let dnaSingleBlockEncoding = DNASingleBlockEncoding()
}