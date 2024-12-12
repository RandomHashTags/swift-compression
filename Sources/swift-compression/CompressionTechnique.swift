//
//  CompressionTechnique.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

public enum CompressionTechnique {
    case aac
    case arithmeticCoding
    case brotli
    case bzip2
    case deflate
    case huffmanCoding
    case h264
    case h265
    case jpeg
    case jpeg2000
    case lz4
    case lz77
    case lz78
    case lzw
    case mp3
    case mpeg
    case runLengthEncoding(minRun: Int)
    /// AKA Zippy
    case snappy
    /// AKA Zippy Framed
    case snappyFramed
    case zstd
    
    @inlinable
    func compress(data: Data) -> CompressionResult {
        guard !data.isEmpty else { return CompressionResult(data: data) }
        switch self {
            case .deflate: return Deflate.compress(data: data)
            case .huffmanCoding: return Huffman.compress(data: data)
            case .runLengthEncoding(let minRun): return RunLengthEncoding.compress(minRun: minRun, data: data)
            case .snappy: return Snappy.compress(data: data)
            default: return CompressionResult(data: data)
        }
    }

    @inlinable
    func decompress(data: Data) -> Data {
        guard !data.isEmpty else { return data }
        switch self {
            case .deflate: return Deflate.decompress(data: data)
            case .huffmanCoding: return Huffman.decompress(data: data)
            case .runLengthEncoding(_): return RunLengthEncoding.decompress(data: data)
            case .snappy: return Snappy.decompress(data: data)
            default: return data
        }
    }
}