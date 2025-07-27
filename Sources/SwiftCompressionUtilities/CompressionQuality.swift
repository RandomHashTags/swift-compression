
/// Quality of the compressed data a compression algorithm uses.
/// 
/// https://en.wikipedia.org/wiki/Data_compression
public enum CompressionQuality {
    /// Data is compressed/decompressed without losing any information.
    case lossless

    /// Data is compressed/decompressed making inexact approximations or losing information.
    case lossy
}