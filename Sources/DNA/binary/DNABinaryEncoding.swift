
import SwiftCompressionUtilities

/// The DNA binary encoding compression technique.
public struct DNABinaryEncoding: Sendable {        
    public let baseBits:[UInt8:UInt8]

    public init(baseBits: [UInt8:UInt8] = [
        65: 0, // A (0, 0)
        67: 1, // C (0, 1)
        71: 2, // G (1, 0)
        84: 3  // T (1, 1)
    ]) {
        self.baseBits = baseBits
    }

    public var algorithm: CompressionAlgorithm {
        .dnaBinaryEncoding(baseBits: baseBits)
    }

    public var compressionQuality: CompressionQuality {
        .lossless
    }

    public var baseBitsReversed: [UInt8:UInt8] {
        var reversed = [UInt8:UInt8]()
        reversed.reserveCapacity(baseBits.count)
        for (byte, bits) in baseBits {
            reversed[bits] = byte
        }
        return reversed
    }
}