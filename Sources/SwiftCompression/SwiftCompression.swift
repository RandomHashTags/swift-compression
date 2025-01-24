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
        case .brotli(let windowSize):
            return CompressionTechnique.brotli(windowSize: windowSize)
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
                let lz:CompressionTechnique.LZ77<UInt128> = CompressionTechnique.lz77<UInt128>(windowSize: windowSize, bufferSize: bufferSize)
                return lz
            #endif
            default: return nil
            }
        case .runLengthEncoding(let minRun, let alwaysIncludeRunCount): return CompressionTechnique.runLength(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        case .snappy: return CompressionTechnique.snappy
        case .snappyFramed: return CompressionTechnique.snappyFramed

        case .dnaBinaryEncoding(let baseBits): return CompressionTechnique.dnaBinaryEncoding(baseBits: baseBits)
        case .dnaSingleBlockEncoding: return CompressionTechnique.dnaSingleBlockEncoding

        case .iwa(let version): return CompressionTechnique.iwa(version: version)

        case .programmingLanguage(let lang):
            switch lang {
            case .css: return CompressionTechnique.css
            case .javascript: return CompressionTechnique.javascript
            case .swift: return CompressionTechnique.swift
            }
        default: return nil
        }
    }
}