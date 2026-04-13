
extension CompressionAlgorithm {
    /// Compressor technique used for this algorithm.
    public var technique: (any Compressor)? {
        switch self {
        case .unknown: return nil
        case .aac: return nil
        case .mp3: return nil

        case .arithmetic: return nil
        case .brotli(let quality, let windowSize, let mode):
            #if Brotli
            return Brotli(quality: quality, windowSize: windowSize, mode: mode)
            #else
            return nil
            #endif
        case .bwt: return nil
        case .deflate(let bufferSize, let level):
            #if ZlibDeflate
            return Deflate(bufferSize: bufferSize, level: level)
            #else
            return nil
            #endif
        case .huffmanCoding:
            #if Huffman
            return Huffman()
            #else
            return nil
            #endif
        case .lz4: return nil
        case .lz77(let windowSize, let bufferSize, let offsetBitWidth):
            #if LZ77
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
            #else
            return nil
            #endif
        case .lz78: return nil
        case .lzw: return nil
        case .mtf: return nil
        case .runLengthEncoding(let minRun, let alwaysIncludeRunCount):
            #if RunLengthEncoding
            return RunLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
            #else
            return nil
            #endif
        case .snappy:
            #if Snappy
            return Snappy()
            #else
            return nil
            #endif
        case .snappyFramed:
            //return SnappyFramed()
            return nil
        case .zstd: return nil

        case ._7z: return nil
        case .bzip2: return nil
        case .gzip(let bufferSize, let level, let memLevel, let strategy):
            #if ZlibGzip
            return Gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)
            #else
            return nil
            #endif
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
            return DNABinaryEncoding(baseBits: baseBits)
        case .dnaSingleBlockEncoding:
            return DNASingleBlockEncoding()

        case .boringSSL: return nil

        case .av1: return nil
        case .dirac: return nil
        case .mpeg: return nil

        case .iwa(let version):
            return IWA(version: version)

        @unknown default: return nil
        }
    }
}