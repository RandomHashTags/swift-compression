//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

@_exported import DNA
@_exported import CSS
@_exported import JavaScript
@_exported import LZ
@_exported import Snappy
@_exported import SwiftCompressionUtilities

// MARK: Technique
extension CompressionAlgorithm {
    /// Compressor technique used for this algorithm.
    @inlinable
    public var technique : (any Compressor)? {
        switch self {
        case .unknown: return nil
        case .aac: return nil
        case .mp3: return nil

        case .arithmetic: return nil
        case .brotli(let windowSize):
            return CompressionTechnique.brotli(windowSize: windowSize)
        case .bwt: return nil
        case .deflate: return nil
        case .huffmanCoding: return nil
        case .json: return nil
        case .lz4: return nil
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
            #if compiler(>=6.0)
            case 128:
                if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                    let lz:CompressionTechnique.LZ77<UInt128> = CompressionTechnique.lz77<UInt128>(windowSize: windowSize, bufferSize: bufferSize)
                    return lz
                }
                return nil
            #endif
            default: return nil
            }
        case .lz78: return nil
        case .lzw: return nil
        case .mtf: return nil
        case .runLengthEncoding(let minRun, let alwaysIncludeRunCount): return CompressionTechnique.runLength(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        case .snappy(let windowSize): return CompressionTechnique.snappy(windowSize: windowSize)
        case .snappyFramed: return CompressionTechnique.snappyFramed
        case .zstd: return nil

        case ._7z: return nil
        case .bzip2: return nil
        case .gzip: return nil
        case .rar: return nil

        case .h264: return nil
        case .h265: return nil
        case .jpeg: return nil
        case .jpeg2000: return nil

        case .eliasDelta: return nil
        case .eliasGamma: return nil
        case .eliasOmega: return nil
        case .fibonacci: return nil

        case .dnaBinaryEncoding(let baseBits): return CompressionTechnique.dnaBinaryEncoding(baseBits: baseBits)
        case .dnaSingleBlockEncoding: return CompressionTechnique.dnaSingleBlockEncoding

        case .boringSSL: return nil

        case .av1: return nil
        case .dirac: return nil
        case .mpeg: return nil

        case .iwa(let version): return CompressionTechnique.iwa(version: version)

        case .programmingLanguage(let lang):
            switch lang {
            case .css: return CompressionTechnique.css
            case .javascript: return CompressionTechnique.javascript
            case .swift: return CompressionTechnique.swift
            @unknown default: return nil
            }
        @unknown default: return nil
        }
    }
}