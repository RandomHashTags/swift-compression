
import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The Snappy Framed compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Snappy_(compression)#Framing_format
    /// 
    /// https://github.com/google/snappy
    public static let snappyFramed:SnappyFramed = SnappyFramed()

    public struct SnappyFramed: Compressor, Decompressor {        
        @inlinable public var algorithm: CompressionAlgorithm { .snappyFramed }
        @inlinable public var quality: CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.SnappyFramed { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.SnappyFramed { // TODO: finish
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte is decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) {
    }
}