//
//  CompressionTechnique.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

public enum CompressionTechnique {
    // audio
    case aac
    case mp3

    // data
    case arithmetic
    case brotli
    /// Burrows–Wheeler transform
    case bwt
    case deflate
    case huffman
    case json
    case lz4
    case lz77(windowSize: Int, bufferSize: Int)
    case lz78
    case lzw
    /// Move-to-front transform
    case mtf
    case runLength(minRun: Int)
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
    case dnacSBE

    // SSL
    case boringSSL

    // video
    case av1
    case dirac
    case mpeg
    
    @inlinable
    public func compress(data: Data) -> CompressionResult {
        guard !data.isEmpty else { return CompressionResult(data: data) }
        switch self {
            case .deflate: return Deflate.compress(data: data)
            case .huffman: return Huffman.compress(data: data)
            case .lz77(let windowSize, let bufferSize): return LZ77.compress(data: data, windowSize: windowSize, bufferSize: bufferSize)
            case .runLength(let minRun): return RunLengthEncoding.compress(minRun: minRun, data: data)
            case .snappy: return Snappy.compress(data: data)
            default: return CompressionResult(data: data)
        }
    }

    @inlinable
    public func decompress(data: Data) -> Data {
        guard !data.isEmpty else { return data }
        switch self {
            case .deflate: return Deflate.decompress(data: data)
            case .huffman: return Huffman.decompress(data: data)
            case .runLength(_): return RunLengthEncoding.decompress(data: data)
            case .snappy: return Snappy.decompress(data: data)
            default: return data
        }
    }
}