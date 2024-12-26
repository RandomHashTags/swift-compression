//
//  CompressionAlgorithm.swift
//
//
//  Created by Evan Anderson on 12/26/24.
//

// MARK: CompressionAlgorithm
/// A collection of well-known and useful compression and decompression algorithms.
public enum CompressionAlgorithm : Hashable, Sendable {
    // audio
    case aac
    case mp3

    // data
    case arithmetic
    case brotli
    /// Burrows–Wheeler transform
    case bwt
    case deflate
    case huffmanCoding
    case json
    case lz4
    case lz77(windowSize: Int, bufferSize: Int, offsetBitWidth: Int)
    case lz78
    case lzw
    /// Move-to-front transform
    case mtf
    case runLengthEncoding(minRun: Int, alwaysIncludeRunCount: Bool)
    /// AKA Zippy
    case snappy
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
}

// MARK: RawValue
public extension CompressionAlgorithm {
    /// The case name of the algorithm.
    var rawValue : String {
        switch self {
        case .aac: return "aac"
        case .mp3: return "mp3"

        case .arithmetic: return "arithmetic"
        case .brotli: return "brotli"

        case .bwt: return "bwt"
        case .deflate: return "deflate"
        case .huffmanCoding: return "huffmanCoding"
        case .json: return "json"
        case .lz4: return "lz4"
        case .lz77(_, _, _): return "lz77"
        case .lz78: return "lz78"
        case .lzw: return "lzw"
        case .mtf: return "mtf"
        case .runLengthEncoding: return "runLengthEncoding"
        case .snappy: return "snappy"
        case .snappyFramed: return "snappyFramed"
        case .zstd: return "zstd"

        case ._7z: return "_7z"
        case .bzip2: return "bzip2"
        case .gzip: return "gzip"
        case .rar: return "rar"
        
        case .h264: return "h264"
        case .h265: return "h265"
        case .jpeg: return "jpeg"
        case .jpeg2000: return "jpeg2000"

        case .eliasDelta: return "eliasDelta"
        case .eliasGamma: return "eliasGamma"
        case .eliasOmega: return "eliasOmega"
        case .fibonacci: return "fibonacci"

        case .dnaBinaryEncoding: return "dnaBinaryEncoding"
        case .dnaSingleBlockEncoding: return "dnaSingleBlockEncoding"

        case .boringSSL: return "boringSSL"

        case .av1: return "av1"
        case .dirac: return "dirac"
        case .mpeg: return "mpeg"
        }
    }
}

// MARK: Technique
public extension CompressionAlgorithm {
    @inlinable
    var technique : (any Compressor)? {
        switch self {
        case .lz77(let windowSize, let bufferSize, let offsetBitWidth):
            switch offsetBitWidth {
                case 8:
                    let lz:CompressionTechnique.LZ77<UInt8> = CompressionTechnique.lz77<UInt8>(windowSize: windowSize, bufferSize: bufferSize)
                    return lz
                case 16:
                    let lz:CompressionTechnique.LZ77<UInt16> = CompressionTechnique.lz77<UInt16>(windowSize: windowSize, bufferSize: bufferSize)
                    return lz
                case 32:
                    let lz:CompressionTechnique.LZ77<UInt32> = CompressionTechnique.lz77<UInt32>(windowSize: windowSize, bufferSize: bufferSize)
                    return lz
                case 64:
                    let lz:CompressionTechnique.LZ77<UInt64> = CompressionTechnique.lz77<UInt64>(windowSize: windowSize, bufferSize: bufferSize)
                    return lz
                default: return nil
            }
        case .runLengthEncoding(let minRun, let alwaysIncludeRunCount): return CompressionTechnique.runLength(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        case .snappy: return CompressionTechnique.snappy

        case .dnaBinaryEncoding(let baseBits): return CompressionTechnique.dnaBinaryEncoding(baseBits: baseBits)
        default: return nil
        }
    }
}