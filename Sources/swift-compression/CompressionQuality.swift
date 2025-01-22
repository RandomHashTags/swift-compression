//
//  CompressionQuality.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

/// Quality of the compressed data a compression algorithm uses.
/// 
/// https://en.wikipedia.org/wiki/Data_compression
public enum CompressionQuality {
    /// Compressed data can be decompressed without losing any information.
    case lossless

    /// Compressed data is decompressed by making inexact approximations, losing information.
    case lossy
}