//
//  LZ77.swift
//
//
//  Created by Evan Anderson on 12/12/24.
//

public extension CompressionTechnique {
    /// The LZ77 compression technique.
    /// 
    /// - Parameters:
    ///   - windowSize: The size of the sliding window, measured in bytes.
    ///   - bufferSize: The size of the buffer, measured in bytes.
    ///   - offsetType: The integer type the offset is encoded as.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    @inlinable
    static func lz77<T: FixedWidthInteger & Sendable>(windowSize: Int, bufferSize: Int, offsetType: T.Type = UInt16.self) -> LZ77<T> {
        return LZ77(windowSize: windowSize, bufferSize: bufferSize, offsetType: offsetType)
    }
    
    struct LZ77<T: FixedWidthInteger & Sendable> : Compressor {
        public typealias CompressClosureParameters = UInt8
        public typealias DecompressClosureParameters = UInt8
        /// The size of the window.
        public let windowSize:Int

        /// The size of the buffer.
        public let bufferSize:Int

        /// The integer type the offset is encoded as.
        public let offsetType:T.Type

        public init(windowSize: Int, bufferSize: Int, offsetType: T.Type = UInt16.self) {
            self.windowSize = windowSize
            self.bufferSize = bufferSize
            self.offsetType = offsetType
        }

        public var rawValue: String { "lz77" }
    }
}

// MARK: Compress
public extension CompressionTechnique.LZ77 {
    /// Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - closure: The logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func compress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        let count:Int = data.count
        var index:Int = 0
        while index < count {
            let bufferEndIndex:Int = min(index + bufferSize, count)
            guard index < bufferEndIndex else { break }
            let bufferCount:Int = bufferEndIndex - index
            let bufferRange:Range<C.Index> = data.index(data.startIndex, offsetBy: index)..<data.index(data.startIndex, offsetBy: bufferEndIndex)
            let buffer:C.SubSequence = data[bufferRange]
            let windowRange:Range<C.Index> = data.index(data.startIndex, offsetBy: max(0, index - windowSize))..<data.index(data.startIndex, offsetBy: index)
            let window:C.SubSequence = data[windowRange], windowCount:Int = window.count
            var offset:Int = 0, bestLength:Int = 0
            for i in 0..<windowSize {
                var length:Int = 0
                while length < bufferCount && window.get(window.index(window.startIndex, offsetBy: i + length)) == buffer[buffer.index(buffer.startIndex, offsetBy: length)] {
                    length += 1
                    if i + length >= windowCount {
                        break
                    }
                }
                if length > bestLength {
                    bestLength = length
                    offset = windowCount - i
                }
            }
            let byte:UInt8
            if index + bestLength < count {
                byte = data[data.index(data.startIndex, offsetBy: index + bestLength)]
            } else {
                byte = 0
            }
            for byte in T(offset).reversedBytes {
                closure(byte)
            }
            closure(UInt8(bestLength))
            closure(byte)
            index += bestLength + 1
        }
        return nil
    }
}

// MARK: Decompress
public extension CompressionTechnique.LZ77 {
    /// Decompress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - closure: The logic to execute when a byte was decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) {
        let count:Int = data.count
        var history:[UInt8] = []
        var window:[UInt8] = []
        var index:Int = 0
        let bytesForOffset:Int = T.bitWidth / 8, byteIndexOffset:Int = bytesForOffset + 1
        let parseOffset:(_ index: Int) -> T?
        switch bytesForOffset {
        case 0:
            return
        case 1:
            parseOffset = { index in
                return UInt8(fromBits: data[data.index(data.startIndex, offsetBy: index)].bitsTuple) as? T
            }
        case 2:
            parseOffset = { index in
                return UInt16(highBits: data[data.index(data.startIndex, offsetBy: index)].bitsTuple, lowBits: data[data.index(data.startIndex, offsetBy: index+1)].bitsTuple) as? T
            }
        case 4:
            parseOffset = { index in
                return UInt32(
                    data[data.index(data.startIndex, offsetBy: index)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+1)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+2)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+3)].bitsTuple
                ) as? T
            }
        case 8:
            parseOffset = { index in
                return UInt64(
                    data[data.index(data.startIndex, offsetBy: index)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+1)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+2)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+3)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+4)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+5)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+6)].bitsTuple,
                    data[data.index(data.startIndex, offsetBy: index+7)].bitsTuple
                ) as? T
            }
        default:
            parseOffset = { index in
                var bits:[Bool] = data[data.index(data.startIndex, offsetBy: index)].bits
                if bytesForOffset > 1 {
                    for i in 1..<bytesForOffset {
                        bits.append(contentsOf: data[data.index(data.startIndex, offsetBy: index + i)].bits)
                    }
                }
                return T(fromBits: bits)
            }
        }
        while index < count {
            let length:Int = Int(data[data.index(data.startIndex, offsetBy: index + bytesForOffset)])
            if length > 0, let offset:T = parseOffset(index) {
                let startIndex:Int = window.count - Int(offset)
                let endIndex:Int = min(startIndex + length, window.count)
                if startIndex < endIndex {
                    let bytes:ArraySlice<UInt8> = window[startIndex..<endIndex]
                    for byte in bytes {
                        closure(byte)
                        history.append(byte)
                    }
                }
            }
            let byte:UInt8 = data[data.index(data.startIndex, offsetBy: index + byteIndexOffset)]
            if byte != 0 {
                closure(byte)
                history.append(byte)
            }
            window.append(contentsOf: history.suffix(length + 1))
            if window.count > windowSize {
                window.removeFirst(window.count - windowSize)
            }
            index += bytesForOffset + 2
        }
    }
}