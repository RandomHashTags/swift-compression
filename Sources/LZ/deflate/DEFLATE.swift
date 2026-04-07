
import SwiftCompressionUtilities

// https://en.wikipedia.org/wiki/Gzip
// https://www.rfc-editor.org/rfc/rfc1952#page-5

/// The Deflate compression technique.
/// 
/// https://en.wikipedia.org/wiki/Deflate
public enum Deflate {
    struct Block: Sendable {
        let head:Head
    }
}

// MARK: Head
extension Deflate {
    struct Head: Sendable {
        let bits:UInt8

        var isLastBlockInStream: Bool {
            bits & 1 > 0
        }

        var encoding: Encoding {
            switch (bits & 0b00000011) {
            case 0: .stored
            case 1: .staticHuffman
            case 2: .dynamicHuffman
            default: .reserved
            }
        }
    }
}

// MARK: Encoding
extension Deflate {
    public enum Encoding: ~Copyable, Sendable {
        /// A stored (a.k.a. raw or literal) section, between 0 and 65,535 bytes in length
        case stored

        /// A _static Huffman_ compressed block, using a pre-agreed [Huffman tree](https://en.wikipedia.org/wiki/Huffman_coding) defined in the RFC
        case staticHuffman

        /// A _dynamic Huffman_ compressed block, complete with the Huffman table supplied
        case dynamicHuffman

        /// Reserved: don't use
        case reserved
    }
}

// MARK: Flags
extension Deflate {
    public struct Flags: ~Copyable, Sendable {
        let bits:UInt8

        public init(
            FTEXT: Bool,
            FHCRC: Bool,
            FEXTRA: Bool,
            FNAME: Bool,
            FCOMMENT: Bool
        ) {
            bits = (FTEXT ? 1 : 0)
                | (FHCRC ? 2 : 0)
                | (FEXTRA ? 4 : 0)
                | (FNAME ? 8 : 0)
                | (FCOMMENT ? 16 : 0)
        }

        /// - Warning: Make sure `flags` is in little-endian!
        public init(flags: UInt8) {
            self.bits = flags
        }
    }
}

// MARK: Quality
extension Deflate {
    public enum Quality: ~Copyable, Sendable {
        case `default`

        /// Best compression (level 9)
        case best

        /// Fastest compression (level 1)
        case fastest

        var rawValue: UInt8 {
            switch self {
            case .default: 0
            case .best: 2
            case .fastest: 4
            }
        }
    }
}

// MARK: FileSystem
extension Deflate {
    public enum FileSystem: ~Copyable, Sendable {
        case fat
        case amiga
        case openVMS
        case unix
        case vmCMS
        case atariTOS
        case hpfs
        case macintosh
        case zsystem
        case cpm
        case tops20
        case ntfs
        case qdos
        case acornRISCOS
        case unknown

        var rawValue: UInt8 {
            switch self {
            case .fat:         0
            case .amiga:       1
            case .openVMS:     2
            case .unix:        3
            case .vmCMS:       4
            case .atariTOS:    5
            case .hpfs:        6
            case .macintosh:   7
            case .zsystem:     8
            case .cpm:         9
            case .tops20:      10
            case .ntfs:        11
            case .qdos:        12
            case .acornRISCOS: 13
            case .unknown:     255
            }
        }
    }
}