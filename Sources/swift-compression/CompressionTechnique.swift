//
//  CompressionTechnique.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: CompressionTechnique
/// A collection of well-known and useful compression and decompression techniques.
public enum CompressionTechnique : Compressor {
    public func compress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
    public func decompress<C: Collection<UInt8>>(data: C, closure: (UInt8) -> Void) {
    }

    case multiple(techniques: [CompressionTechnique])

    // audio
    case aac
    case mp3

    // data
    case arithmetic
    case brotli
    /// Burrows–Wheeler transform
    case bwt
    case deflate
    case huffman(rootNode: Huffman.Node?)
    case json
    case lz4

    case lz78
    case lzw
    /// Move-to-front transform
    case mtf
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
    case dnaSingleBlockEncoding

    // SSL
    case boringSSL

    // video
    case av1
    case dirac
    case mpeg    
}

// MARK: RawValue
public extension CompressionTechnique {
    /// The case name of the technique.
    var rawValue : String {
        switch self {
        case .multiple: return "multiple"

        case .aac: return "aac"
        case .mp3: return "mp3"

        case .arithmetic: return "arithmetic"
        case .brotli: return "brotli"

        case .bwt: return "bwt"
        case .deflate: return "deflate"
        case .huffman: return "huffman"
        case .json: return "json"
        case .lz4: return "lz4"
        case .lz78: return "lz78"
        case .lzw: return "lzw"
        case .mtf: return "mtf"
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

        case .dnaSingleBlockEncoding: return "dnaSingleBlockEncoding"

        case .boringSSL: return "boringSSL"

        case .av1: return "av1"
        case .dirac: return "dirac"
        case .mpeg: return "mpeg"
        }
    }
}

// MARK: Compress
public extension CompressionTechnique {
    /// Compress a collection of bytes using the given technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress<C: Collection<UInt8>>(data: C) -> CompressionResult<[UInt8]>? {
        guard !data.isEmpty else { return nil }
        switch self {
            case .multiple(let techniques):
                var result:CompressionResult<[UInt8]> = CompressionResult(data: [UInt8](data))
                for technique in techniques {
                    if let compressed:CompressionResult<[UInt8]> = technique.compress(data: result.data) {
                        result.data = compressed.data
                        result.rootNode = compressed.rootNode
                    }
                }
                return result
            case .deflate:                                          return Deflate.compress(data: data)
            case .dnaSingleBlockEncoding:                           return DNASingleBlockEncoding.compress(data: data)
            case .huffman(_):                                       return Huffman.compress(data: data)
            case .json:                                             return JSON.compress(data: data)
            default:                                                return nil
        }
    }

    /// Compress a sequence of bytes into a stream using the given technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress(
        data: [UInt8],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> CompressionResult<AsyncStream<UInt8>>? {
        guard !data.isEmpty else { return nil }
        switch self {
        case .huffman(_):
            return Huffman.compress(data: data, bufferingPolicy: limit)
        default:
            let stream:AsyncStream<UInt8> = AsyncStream(bufferingPolicy: limit) { continuation in
                continuation.finish()
            }
            return CompressionResult(data: stream)
        }
    }
}

// MARK: Decompress
public extension CompressionTechnique {
    /// Decompress a sequence of bytes using the given technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func decompress(data: [UInt8]) -> [UInt8] {
        guard !data.isEmpty else { return data }
        switch self {
        case .multiple(let techniques):
            var data:[UInt8] = data
            for technique in techniques {
                data = technique.decompress(data: data)
            }
            return data
        case .deflate: return Deflate.decompress(data: data)
        case .dnaSingleBlockEncoding: return DNASingleBlockEncoding.decompress(data: data)
        case .huffman(let root): return Huffman.decompress(data: data, root: root)
        case .json: return JSON.decompress(data: data)
        default: return data
        }
    }
    
    /// Decompress a sequence of bytes into a stream using the given technique.
    /// 
    /// - Parameters:
    ///   - data: The sequence of bytes to decompress.
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func decompress(
        data: [UInt8],
        bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<UInt8> {
        guard !data.isEmpty else { return AsyncStream { $0.finish() } }
        let stream:AsyncStream<UInt8> = AsyncStream(bufferingPolicy: limit) { continuation in
            switch self {
            case .huffman(let root): Huffman.decompress(data: data, root: root, continuation: continuation)
            default: break
            }
            continuation.finish()
        }
        return stream
    }
}

// MARK: Frequency tables
public extension CompressionTechnique {
    /// Creates a universal frequency table from a sequence of raw bytes.
    /// 
    /// - Parameters:
    ///   - data: A sequence of raw bytes.
    /// - Returns: A universal frequency table.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func buildFrequencyTable<S: Sequence<UInt8>>(data: S) -> [Int] {
        var table:[Int] = Array(repeating: 0, count: 255)
        for byte in data {
            table[Int(byte)] += 1
        }
        return table
    }

    /// Creates a lookup frequency table from a sequence of raw bytes.
    /// 
    /// - Parameters:
    ///   - data: A sequence of raw bytes.
    /// - Returns: A lookup frequency table.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func buildFrequencyTable<S: Sequence<UInt8>>(data: S) -> [UInt8:Int] {
        var table:[UInt8:Int] = [:]
        for byte in data {
            table[byte, default: 0] += 1
        }
        return table
    }

    /// Creates a universal frequency table from a character frequency dictionary.
    /// 
    /// - Parameters:
    ///   - chars: A frequency table that represents how many times a character is present.
    /// - Returns: A universal frequency table.
    /// - Complexity: O(_n_) where _n_ is the sum of the `Character` utf8 lengths in `chars`.
    @inlinable
    static func buildFrequencyTable(chars: [Character:Int]) -> [Int] {
        var table:[Int] = Array(repeating: 0, count: 255)
        for (char, freq) in chars {
            for byte in char.utf8 {
                table[Int(byte)] = freq
            }
        }
        return table
    }
}