//
//  LZ77.swift
//
//
//  Created by Evan Anderson on 12/12/24.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The LZ77 compression technique.
    /// 
    /// - Parameters:
    ///   - T: Integer type the offset is encoded as. Default is `UInt16`.
    ///   - windowSize: Size of the sliding window, measured in bytes.
    ///   - bufferSize: Size of the buffer, measured in bytes.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    @inlinable
    public static func lz77<T: FixedWidthInteger & Sendable>(windowSize: Int, bufferSize: Int) -> LZ77<T> {
        return LZ77(windowSize: windowSize, bufferSize: bufferSize)
    }

    /// The LZ77 compression technique where the offset is encoded as a `UInt16`.
    /// 
    /// - Parameters:
    ///   - windowSize: Size of the sliding window, measured in bytes.
    ///   - bufferSize: Size of the buffer, measured in bytes.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    @inlinable
    public static func lz77(windowSize: Int, bufferSize: Int) -> LZ77<UInt16> {
        return LZ77(windowSize: windowSize, bufferSize: bufferSize)
    }
    
    public struct LZ77<T: FixedWidthInteger & Sendable> : Compressor, Decompressor {
        /// Size of the window.
        public let windowSize:Int

        /// Size of the buffer.
        public let bufferSize:Int

        public init(windowSize: Int, bufferSize: Int) {
            self.windowSize = windowSize
            self.bufferSize = bufferSize
        }

        @inlinable public var algorithm : CompressionAlgorithm { .lz77(windowSize: windowSize, bufferSize: bufferSize, offsetBitWidth: T.bitWidth) }
        @inlinable public var quality : CompressionQuality { .lossless }
    }
}

// MARK: Compress
extension CompressionTechnique.LZ77 {
    /// Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<C: Collection<UInt8>>(
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
                while length < bufferCount && window.get(window.index(window.startIndex, offsetBy: i + length)) == buffer[length] {
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
                byte = data[index + bestLength]
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
extension CompressionTechnique.LZ77 {
    /// Decompress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte was decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func decompress<C: Collection<UInt8>>(
        data: C,
        closure: (UInt8) -> Void
    ) {
        let count:Int = data.count
        var history:[UInt8] = []
        var window:[UInt8] = []
        var index:Int = 0
        let bytesForOffset:Int = T.bitWidth / 8, byteIndexOffset:Int = bytesForOffset + 1
        while index < count {
            let length:Int = Int(data[index + bytesForOffset])
            if length > 0 {
                let offset:T = parseOffset(data: data, index: index)
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
            let byte:UInt8 = data[index + byteIndexOffset]
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

    @inlinable
    func parseOffset<C: Collection<UInt8>>(data: C, index: Int) -> T {
        var byte:T = T()
        var offsetIndex:Int = index
        for _ in 0...(T.bitWidth / 8)-1 {
            byte <<= 8
            byte += T(data[offsetIndex])
            offsetIndex += 1
        }
        return byte
    }
}