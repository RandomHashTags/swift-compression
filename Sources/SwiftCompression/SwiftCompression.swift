
@_exported import CompressionDNA
@_exported import CompressionLZ
@_exported import CompressionSnappy
@_exported import Zlib
@_exported import SwiftCompressionUtilities

// MARK: Technique
extension CompressionAlgorithm {
    /// Compressor technique used for this algorithm.
    public var technique: (any Compressor)? {
        switch self {
        case .unknown: return nil
        case .aac: return nil
        case .mp3: return nil

        case .arithmetic: return nil
        case .brotli(let windowSize):
            //return CompressionTechnique.brotli(windowSize: windowSize)
            return nil
        case .bwt: return nil
        case .deflate(let bufferSize, let level):
            return Deflate(bufferSize: bufferSize, level: level)
        case .huffmanCoding: return nil
        case .lz4: return nil
        case .lz77(let windowSize, let bufferSize, let offsetBitWidth):
            switch offsetBitWidth {
            case 8:
                return LZ77<UInt8>(windowSize: windowSize, bufferSize: bufferSize)
            case 16:
                return LZ77<UInt16>(windowSize: windowSize, bufferSize: bufferSize)
            case 32:
                return LZ77<UInt32>(windowSize: windowSize, bufferSize: bufferSize)
            case 64:
                return LZ77<UInt64>(windowSize: windowSize, bufferSize: bufferSize)
            #if compiler(>=6.0)
            case 128:
                if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                    return LZ77<UInt128>(windowSize: windowSize, bufferSize: bufferSize)
                }
                return nil
            #endif
            default: return nil
            }
        case .lz78: return nil
        case .lzw: return nil
        case .mtf: return nil
        case .runLengthEncoding(let minRun, let alwaysIncludeRunCount):
            return CompressionTechnique.runLength(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        case .snappy(let windowSize):
            //return CompressionTechnique.snappy(windowSize: windowSize)
            return nil
        case .snappyFramed:
            //return CompressionTechnique.snappyFramed
            return nil
        case .zstd: return nil

        case ._7z: return nil
        case .bzip2: return nil
        case .gzip(let bufferSize, let level, let memLevel, let strategy):
            return Gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)
        case .rar: return nil

        case .h264: return nil
        case .h265: return nil
        case .jpeg: return nil
        case .jpeg2000: return nil

        case .eliasDelta: return nil
        case .eliasGamma: return nil
        case .eliasOmega: return nil
        case .fibonacci: return nil

        case .dnaBinaryEncoding(let baseBits):
            return CompressionTechnique.dnaBinaryEncoding(baseBits: baseBits)
        case .dnaSingleBlockEncoding:
            return CompressionTechnique.dnaSingleBlockEncoding

        case .boringSSL: return nil

        case .av1: return nil
        case .dirac: return nil
        case .mpeg: return nil

        case .iwa(let version):
            return CompressionTechnique.iwa(version: version)

        @unknown default: return nil
        }
    }
}