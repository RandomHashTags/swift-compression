
// MARK: CompressionAlgorithm
/// Collection of well-known and useful compression and decompression algorithms.
public enum CompressionAlgorithm: Hashable, Sendable {
    case unknown

    // audio
    case aac
    case mp3

    // data
    case arithmetic
    case brotli(windowSize: Int)
    /// Burrows–Wheeler transform
    case bwt
    case deflate
    case huffmanCoding
    case lz4
    case lz77(windowSize: Int, bufferSize: Int, offsetBitWidth: Int)
    case lz78
    case lzw
    /// Move-to-front transform
    case mtf
    case runLengthEncoding(minRun: Int, alwaysIncludeRunCount: Bool)
    /// AKA Zippy
    case snappy(windowSize: Int)
    /// AKA Zippy Framed
    case snappyFramed
    case zstd

    // files
    case _7z
    case bzip2
    case gzip
    case rar

    // image
    case h264
    case h265
    case jpeg
    case jpeg2000

    // math
    case eliasDelta
    case eliasGamma
    case eliasOmega
    case fibonacci

    // science
    case dnaBinaryEncoding(baseBits: [UInt8:[Bool]])
    case dnaSingleBlockEncoding

    // SSL
    case boringSSL

    // video
    case av1
    case dirac
    case mpeg

    // Apple
    /// iWork Archive (Pages, Keynote, Numbers)
    case iwa(version: IWAVersion)
}

// MARK: RawValue
extension CompressionAlgorithm {
    /// Case name of the algorithm.
    public var rawValue: String {
        switch self {
        case .unknown: "unknown"
        
        case .aac: "aac"
        case .mp3: "mp3"

        case .arithmetic: "arithmetic"
        case .brotli: "brotli"

        case .bwt: "bwt"
        case .deflate: "deflate"
        case .huffmanCoding: "huffmanCoding"
        case .lz4: "lz4"
        case .lz77: "lz77"
        case .lz78: "lz78"
        case .lzw: "lzw"
        case .mtf: "mtf"
        case .runLengthEncoding: "runLengthEncoding"
        case .snappy: "snappy"
        case .snappyFramed: "snappyFramed"
        case .zstd: "zstd"

        case ._7z: "_7z"
        case .bzip2: "bzip2"
        case .gzip: "gzip"
        case .rar: "rar"
        
        case .h264: "h264"
        case .h265: "h265"
        case .jpeg: "jpeg"
        case .jpeg2000: "jpeg2000"

        case .eliasDelta: "eliasDelta"
        case .eliasGamma: "eliasGamma"
        case .eliasOmega: "eliasOmega"
        case .fibonacci: "fibonacci"

        case .dnaBinaryEncoding: "dnaBinaryEncoding"
        case .dnaSingleBlockEncoding: "dnaSingleBlockEncoding"

        case .boringSSL: "boringSSL"

        case .av1: "av1"
        case .dirac: "dirac"
        case .mpeg: "mpeg"

        case .iwa: "iwa"

        @unknown default: "unknown"
        }
    }
}