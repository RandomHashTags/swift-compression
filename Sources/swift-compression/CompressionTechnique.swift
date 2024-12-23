//
//  CompressionTechnique.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: CompressionTechnique
/// A collection of well-known and useful compression and decompression techniques.
public enum CompressionTechnique : Hashable, Sendable {
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
    case lz77(windowSize: Int, bufferSize: Int)
    case lz78
    case lzw
    /// Move-to-front transform
    case mtf
    case runLength(minRun: Int, alwaysIncludeRunCount: Bool)
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
    case dnaBinaryEncoding(baseBits: [UInt8:[Bool]] = [
        65 : [false, false], // A
        67 : [false, true],  // C
        71 : [true, false],  // G
        84 : [true, true]    // T
    ])
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
        case .lz77: return "lz77"
        case .lz78: return "lz78"
        case .lzw: return "lzw"
        case .mtf: return "mtf"
        case .runLength: return "runLength"
        case .snappy: return "snappy"
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

        case .dnaBinaryEncoding(_): return "dnaBinaryEncoding"
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
            case .dnaBinaryEncoding(let baseBits):                  return DNABinaryEncoding.compress(data: data, baseBits: baseBits) 
            case .dnaSingleBlockEncoding:                           return DNASingleBlockEncoding.compress(data: data)
            case .huffman(_):                                       return Huffman.compress(data: data)
            case .json:                                             return JSON.compress(data: data)
            case .lz77(let windowSize, let bufferSize):             return LZ77.compress(data: data, windowSize: windowSize, bufferSize: bufferSize)
            case .runLength(let minRun, let alwaysIncludeRunCount): return CompressionResult(data: RunLengthEncoding.compress(data: data, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount))
            case .snappy:                                           return CompressionResult(data: Snappy.compress(data: data))
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
        switch self {
            case .huffman(_):
                return Huffman.compress(data: data, bufferingPolicy: limit)
            case .lz77(let windowSize, let bufferSize):
                return CompressionResult(data: LZ77.compress(data: data, windowSize: windowSize, bufferSize: bufferSize, bufferingPolicy: limit))
            case .runLength(let minRun, let alwaysIncludeRunCount):
                return CompressionResult(data: RunLengthEncoding.compress(data: data, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount, bufferingPolicy: limit))
            default:
                return nil
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
            case .dnaBinaryEncoding(let baseBits):
                var reversed:[[Bool]:UInt8] = [:]
                reversed.reserveCapacity(baseBits.count)
                for (byte, bits) in baseBits {
                    reversed[bits] = byte
                }
                return DNABinaryEncoding.decompress(data: data, baseBits: reversed)
            case .dnaSingleBlockEncoding: return DNASingleBlockEncoding.decompress(data: data)
            case .huffman(let root): return Huffman.decompress(data: data, root: root)
            case .json: return JSON.decompress(data: data)
            case .lz77(let windowSize, _): return LZ77.decompress(data: data, windowSize: windowSize)
            case .runLength(_, _): return RunLengthEncoding.decompress(data: data)
            case .snappy: return Snappy.decompress(data: data)
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
        switch self {
            case .huffman(let root): return Huffman.decompress(data: data, root: root, bufferingPolicy: limit)
            case .dnaBinaryEncoding(let baseBits):
                var reversed:[[Bool]:UInt8] = [:]
                reversed.reserveCapacity(baseBits.count)
                for (byte, bits) in baseBits {
                    reversed[bits] = byte
                }
                return DNABinaryEncoding.decompress(data: data, baseBits: reversed, bufferingPolicy: limit)
            case .lz77(let windowSize, _): return LZ77.decompress(data: data, windowSize: windowSize, bufferingPolicy: limit)
            case .runLength(_, _): return RunLengthEncoding.decompress(data: data, bufferingPolicy: limit)
            case .snappy: return Snappy.decompress(data: data, bufferingPolicy: limit)
            default: return AsyncStream { $0.finish() }
        }
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

// MARK: Stream & Data Builder
public extension CompressionTechnique {
    struct StreamBuilder {
        public var stream:AsyncStream<UInt8>.Continuation
        public var bitBuilder:ByteBuilder

        public init(stream: AsyncStream<UInt8>.Continuation, bitBuilder: ByteBuilder = ByteBuilder()) {
            self.stream = stream
            self.bitBuilder = bitBuilder
        }

        /// - Complexity: O(1).
        @inlinable
        public mutating func write(bit: Bool) {
            if let wrote:UInt8 = bitBuilder.write(bit: bit) {
                stream.yield(wrote)
            }
        }

        /// - Complexity: O(1).
        @inlinable
        public mutating func finalize() {
            bitBuilder.flush(into: stream)
        }
    }
    struct DataBuilder {
        public var data:[UInt8]
        public var bitBuilder:ByteBuilder

        public init(data: [UInt8] = [], bitBuilder: ByteBuilder = ByteBuilder()) {
            self.data = data
            self.bitBuilder = bitBuilder
        }

        @inlinable
        public mutating func write(bit: Bool) {
            if let wrote:UInt8 = bitBuilder.write(bit: bit) {
                data.append(wrote)
            }
        }
        @inlinable
        public mutating func write(bits: [Bool]) {
            bitBuilder.write(bits: bits, closure: { data.append($0) })
        }
        
        @inlinable
        public mutating func finalize() {
            bitBuilder.flush(into: &data)
        }
    }
}