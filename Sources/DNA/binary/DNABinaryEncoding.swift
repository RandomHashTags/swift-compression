
import SwiftCompressionUtilities

/// The DNA binary encoding compression technique.
public struct DNABinaryEncoding: Sendable {        
    public let baseBits:[UInt8:[Bool]]

    public init(baseBits: [UInt8:[Bool]] = [
        65: [false, false], // A
        67: [false, true],  // C
        71: [true, false],  // G
        84: [true, true]    // T
    ]) {
        self.baseBits = baseBits
    }

    public var algorithm: CompressionAlgorithm {
        .dnaBinaryEncoding(baseBits: baseBits)
    }

    public var quality: CompressionQuality {
        .lossless
    }

    public var baseBitsReversed: [[Bool]:UInt8] {
        var reversed = [[Bool]:UInt8]()
        reversed.reserveCapacity(baseBits.count)
        for (byte, bits) in baseBits {
            reversed[bits] = byte
        }
        return reversed
    }
}

extension CompressionTechnique {
    /// The DNA binary encoding compression technique.
    public static func dnaBinaryEncoding(baseBits: [UInt8:[Bool]] = [
        65: [false, false], // A
        67: [false, true],  // C
        71: [true, false],  // G
        84: [true, true]    // T
    ]) -> DNABinaryEncoding {
        return DNABinaryEncoding(baseBits: baseBits)
    }
}