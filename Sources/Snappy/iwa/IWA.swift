
import SwiftCompressionUtilities

/// The iWork Archive (iwa) compression technique.
/// 
/// https://en.wikipedia.org/wiki/IWork
public struct IWA: Sendable {        
    /// Version of the iWork Archive to use.
    public let version:IWAVersion

    public init(version: IWAVersion) {
        self.version = version
    }

    public var algorithm: CompressionAlgorithm {
        .iwa(version: version)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }
}

// MARK: Configuration
extension IWA {
    public struct Configuration: CompressionConfiguration, DecompressionConfiguration {
        public static var `default`: Self { .init() }

        public init() {
        }
    }
}