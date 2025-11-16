
import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The Brotli compression technique.
    /// 
    /// https://github.com/google/brotli
    /// 
    /// https://en.wikipedia.org/wiki/Brotli
    public static func brotli(windowSize: Int = 32768) -> Brotli {
        return Brotli(windowSize: windowSize)
    }

    public struct Brotli: Compressor, Decompressor { // TODO: finish
        /// Size of the window.
        public let windowSize:Int

        /// Predefined dictionary to use.
        //public let dictionary:[String:String]

        public init(windowSize: Int = 32768) {
            self.windowSize = windowSize
        }

        @inlinable
        public var algorithm: CompressionAlgorithm {
            .brotli(windowSize: windowSize)
        }

        @inlinable
        public var quality: CompressionQuality {
            .lossless
        }
    }
}

// MARK: Compress
extension CompressionTechnique.Brotli { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.Brotli { // TODO: finish
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) {
    }
}