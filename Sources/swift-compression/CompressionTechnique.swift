//
//  CompressionTechnique.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: CompressionTechnique
public enum CompressionTechnique {
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
    case dnacSBE

    // SSL
    case boringSSL

    // video
    case av1
    case dirac
    case mpeg
    
    @inlinable
    public func compress(data: [UInt8]) -> CompressionResult<[UInt8]> {
        guard !data.isEmpty else { return CompressionResult(data: data) }
        switch self {
            case .multiple(let techniques):
                var result:CompressionResult = CompressionResult(data: data)
                for technique in techniques {
                    let compressed:CompressionResult<[UInt8]> = technique.compress(data: result.data)
                    result.data = compressed.data
                    result.rootNode = compressed.rootNode
                }
                return result
            case .deflate:                                          return Deflate.compress(data: data)
            case .huffman(_):                                       return Huffman.compress(data: data)
            case .json:                                             return JSON.compress(data: data)
            case .lz77(let windowSize, let bufferSize):             return LZ77.compress(data: data, windowSize: windowSize, bufferSize: bufferSize)
            case .runLength(let minRun, let alwaysIncludeRunCount): return CompressionResult(data: RunLengthEncoding.compress(data: data, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount))
            case .snappy:                                           return CompressionResult(data: Snappy.compress(data: data))
            default:                                                return CompressionResult(data: data)
        }
    }

    @inlinable
    public func compress(data: [UInt8]) -> CompressionResult<AsyncStream<UInt8>> {
        switch self {
            case .huffman(_):
                return Huffman.compress(data: data)
            case .runLength(let minRun, let alwaysIncludeRunCount):
                return CompressionResult(data: RunLengthEncoding.compress(data: data, minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount))
            default:
                return CompressionResult(data: AsyncStream { $0.finish() })
        }
    }

    @inlinable
    public func decompress(data: [UInt8]) -> [UInt8] {
        guard !data.isEmpty else { return data }
        switch self {
            case .multiple(let techniques):
                var data:[UInt8] = data
                for technique in techniques {
                    data = technique.decompress(data: data)
                }
                return data
            case .deflate: return Deflate.decompress(data: data)
            case .huffman(let root): return Huffman.decompress(data: data, root: root)
            case .json: return JSON.decompress(data: data)
            case .runLength(_, _): return RunLengthEncoding.decompress(data: data)
            case .snappy: return Snappy.decompress(data: data)
            default: return data
        }
    }
    
    @inlinable
    public func decompress(data: [UInt8], bufferingPolicy limit: AsyncStream<UInt8>.Continuation.BufferingPolicy = .unbounded) -> AsyncStream<UInt8> {
        guard !data.isEmpty else { return AsyncStream { $0.finish() } }
        switch self {
            case .huffman(let root): return Huffman.decompress(data: data, root: root)
            case .runLength(_, _): return RunLengthEncoding.decompress(data: data, bufferingPolicy: limit)
            case .snappy: return Snappy.decompress(data: data, bufferingPolicy: limit)
            default: return AsyncStream { $0.finish() }
        }
    }
}

// MARK: Stream & Data Builder
public extension CompressionTechnique {
    struct StreamBuilder {
        public var stream:AsyncStream<UInt8>.Continuation
        public var bitBuilder:IntBitBuilder

        public init(stream: AsyncStream<UInt8>.Continuation, bitBuilder: IntBitBuilder = IntBitBuilder()) {
            self.stream = stream
            self.bitBuilder = bitBuilder
        }

        @inlinable
        public mutating func write(bit: Bool) {
            if let wrote:UInt8 = bitBuilder.write(bit: bit) {
                stream.yield(wrote)
            }
        }
        @inlinable
        public mutating func finalize() {
            bitBuilder.flush(into: stream)
        }
    }
    struct DataBuilder {
        public var data:[UInt8]
        public var bitBuilder:IntBitBuilder

        public init(data: [UInt8] = [], bitBuilder: IntBitBuilder = IntBitBuilder()) {
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

// MARK: IntBitBuilder
public extension CompressionTechnique {
    struct IntBitBuilder {
        public var bits:Bits8 = (false, false, false, false, false, false, false, false)
        public var index:UInt8 = 0

        public init() {
        }

        @inlinable
        subscript(_ index: UInt8) -> Bool {
            get {
                switch index {
                    case 0: return bits.0
                    case 1: return bits.1
                    case 2: return bits.2
                    case 3: return bits.3
                    case 4: return bits.4
                    case 5: return bits.5
                    case 6: return bits.6
                    case 7: return bits.7
                    default: return false
                }
            }
            set {
                switch index {
                    case 0: bits.0 = newValue
                    case 1: bits.1 = newValue
                    case 2: bits.2 = newValue
                    case 3: bits.3 = newValue
                    case 4: bits.4 = newValue
                    case 5: bits.5 = newValue
                    case 6: bits.6 = newValue
                    case 7: bits.7 = newValue
                    default: break
                }
            }
        }

        @inlinable
        public mutating func write(bit: Bool) -> UInt8? {
            self[index] = bit
            index += 1
            let result:UInt8?
            if index == 8 {
                result = UInt8(fromBits: self.bits)
                index = 0
            } else {
                result = nil
            }
            return result
        }

        @inlinable
        public mutating func write(bits: [Bool], closure: (UInt8) -> Void) {
            let available_bits:UInt8 = UInt8(min(Int(8 - index), bits.count))
            for i in 0..<available_bits {
                self[index + i] = bits[Int(i)]
            }
            index += available_bits
            guard index == 8 else { return }
            
            closure(UInt8(fromBits: self.bits))
            index = 0

            var remaining:Int = bits.count - Int(available_bits)
            let blocks:Int = remaining / 8, offset:Int = blocks * 8
            remaining -= offset
            for block in 0..<blocks {
                let blockIndex:Int = block * 8
                closure(UInt8(fromBits: (
                    bits[blockIndex],
                    bits[blockIndex + 1],
                    bits[blockIndex + 2],
                    bits[blockIndex + 3],
                    bits[blockIndex + 4],
                    bits[blockIndex + 5],
                    bits[blockIndex + 6],
                    bits[blockIndex + 7]
                )))
            }
            if remaining != 0 {
                let last_bits:UInt8 = UInt8(remaining)
                for i in 0..<last_bits {
                    self[index + i] = bits[offset + Int(i)]
                }
                index += last_bits
            }
        }

        @inlinable
        public mutating func flush() -> (byte: UInt8, bitsFilled: UInt8)? {
            guard index != 8 else { return nil }
            let filled:UInt8 = 8 - index
            while index != 8 {
                self[index] = false
                index += 1
            }
            index = 0
            return (UInt8(fromBits: bits), filled)
        }

        @inlinable
        public mutating func flush(into data: inout [UInt8]) {
            guard let wrote:UInt8 = flush()?.byte else { return }
            data.append(wrote)
        }

        @inlinable
        public mutating func flush(into stream: AsyncStream<UInt8>.Continuation) {
            guard let wrote:UInt8 = flush()?.byte else { return }
            stream.yield(wrote)
        }
    }
}