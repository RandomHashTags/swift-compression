
#if AlgorithmCompress

extension CompressionAlgorithm {
    /// Attempts to compress the span of bytes using the algorithm's default configuration.
    /// - Returns: The compressed data.
    public func compress(span: Span<UInt8>) -> [UInt8]? {
        switch self {

        case .brotli(let quality, let windowSize, let mode):
            #if BrotliCompress
            return Brotli(quality: quality, windowSize: windowSize, mode: mode)
                .compress(span, configuration: .default)
            #else
            return nil
            #endif

        case .deflate(let bufferSize, let level):
            #if ZlibDeflateCompress
            return Deflate(bufferSize: bufferSize, level: level)
                .compress(span, configuration: .default)
            #else
            return nil
            #endif

        case .lz77(let searchBufferSize, let lookaheadBufferSize, let offsetBitWidth):
            #if LZ77Compress
            switch offsetBitWidth {
            case 8:  return LZ77<UInt8>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 16: return LZ77<UInt16>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 32: return LZ77<UInt32>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 64: return LZ77<UInt64>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 128:
                if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                    return LZ77<UInt128>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
                }
                return nil
            default:
                return nil
            }
            #else
            return nil
            #endif

        case .huffmanCoding:
            #if HuffmanCompress
            return Huffman().compress(span, configuration: .default)?.data
            #else
            return nil
            #endif

        case .runLengthEncoding(let minRun, let alwaysIncludeRunCount):
            #if RunLengthEncodingCompress
            return RunLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
                .compress(span, configuration: .default)
            #else
            return nil
            #endif

        case .snappy:
            #if SnappyCompress
            return Snappy().compress(span, configuration: .default)
            #else
            return nil
            #endif

        case .gzip(let bufferSize, let level, let memLevel, let strategy):
            #if ZlibGzipCompress
            return Gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)
                .compress(span, configuration: .default)
            #else
            return nil
            #endif

        default:
            return nil
        }
    }
}

#endif