//
//  LZ77.swift
//
//
//  Created by Evan Anderson on 12/12/24.
//

public extension CompressionTechnique {
    /// The LZ77 compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/LZ77_and_LZ78
    enum LZ77 {
    }
}

// MARK: Compress
public extension CompressionTechnique.LZ77 {
    /// Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - reserveCapacity: The space to reserve for the compressed result.
    ///   - windowSize: The size of the window.
    ///   - bufferSize: The size of the buffer.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<C: Collection<UInt8>>(
        data: C,
        reserveCapacity: Int = 1024,
        windowSize: Int,
        bufferSize: Int
    ) -> CompressionResult<[UInt8]> {
        var compressed:[UInt8] = []    
        compressed.reserveCapacity(reserveCapacity)
        compress(data: data, windowSize: windowSize, bufferSize: bufferSize) { compressed.append($0) }
        return CompressionResult(data: compressed)
    }

    /// Compress a collection of bytes into a stream using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - windowSize: The size of the window.
    ///   - bufferSize: The size of the buffer.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<C: Collection<UInt8>>(
        data: C,
        windowSize: Int,
        bufferSize: Int,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        compress(data: data, windowSize: windowSize, bufferSize: bufferSize) { continuation.yield($0) }
    }

    /// Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to compress.
    ///   - windowSize: The size of the window.
    ///   - bufferSize: The size of the buffer.
    ///   - closure: The logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func compress<C: Collection<UInt8>>(
        data: C,
        windowSize: Int,
        bufferSize: Int,
        closure: (UInt8) -> Void
    ) {
        let count:Int = data.count
        var index:Int = 0
        while index < count {
            let windowStarts:Int = max(0, index - windowSize)
            var offset:Int = 0, bestLength:Int = 0
            let bufferStartIndex:C.Index = data.index(data.startIndex, offsetBy: index)
            let bufferEndIndex:C.Index = data.index(data.startIndex, offsetBy: index + bufferSize, limitedBy: data.endIndex) ?? data.endIndex
            guard bufferStartIndex < bufferEndIndex else { break }
            let bufferRange:Range<C.Index> = bufferStartIndex..<bufferEndIndex
            let buffer:[UInt8] = [UInt8](data[bufferRange]) // TODO: make array slice for better performance
            let windowRange:Range<C.Index> = data.index(data.startIndex, offsetBy: windowStarts)..<data.index(data.startIndex, offsetBy: index)
            let window:[UInt8] = [UInt8](data[windowRange]) // TODO: make array slice for better performance
            for i in 0..<windowSize {
                var length:Int = 0
                while length < buffer.count && window.get(i + length) == buffer[length] {
                    length += 1
                    if i + length >= window.count {
                        break
                    }
                }
                if length > bestLength {
                    bestLength = length
                    offset = window.count - i
                }
            }
            let byte:UInt8
            if index + bestLength < count {
                byte = data[data.index(data.startIndex, offsetBy: index + bestLength)]
            } else {
                byte = 0
            }
            for byte in UInt16(offset).reversedBytes {
                closure(byte)
            }
            closure(UInt8(bestLength))
            closure(byte)
            index += bestLength + 1
        }
    }
}

// MARK: Decompress
public extension CompressionTechnique.LZ77 {
    /// Decompress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - windowSize: The size of the window.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress<C: Collection<UInt8>>(
        data: C,
        windowSize: Int
    ) -> [UInt8] {
        var decompressed:[UInt8] = []
        decompress(data: data, windowSize: windowSize) { decompressed.append($0) }
        return decompressed
    }

    /// Decompress a collection of bytes into a stream using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - windowSize: The size of the window.
    ///   - continuation: The `AsyncStream<UInt8>.Continuation`.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress<C: Collection<UInt8>>(
        data: C,
        windowSize: Int,
        continuation: AsyncStream<UInt8>.Continuation
    ) {
        decompress(data: data, windowSize: windowSize) { continuation.yield($0) }
    }

    /// Decompress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: The collection of bytes to decompress.
    ///   - windowSize: The size of the window.
    ///   - closure: The logic to execute when a byte was decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    static func decompress<C: Collection<UInt8>>(
        data: C,
        windowSize: Int,
        closure: (UInt8) -> Void
    ) {
        let count:Int = data.count
        var history:[UInt8] = []
        var window:[UInt8] = []
        var index:Int = 0
        while index < count {
            let length:Int = Int(data[data.index(data.startIndex, offsetBy: index + 2)])
            if length > 0 {
                let offset:Int = Int(UInt16(highBits: data[data.index(data.startIndex, offsetBy: index)].bitsTuple, lowBits: data[data.index(data.startIndex, offsetBy: index + 1)].bitsTuple))
                let startIndex:Int = window.count - offset
                let endIndex:Int = min(startIndex + length, window.count)
                if startIndex < endIndex {
                    let bytes:ArraySlice<UInt8> = window[startIndex..<endIndex]
                    for byte in bytes {
                        closure(byte)
                        history.append(byte)
                    }
                }
            }
            let byte:UInt8 = data[data.index(data.startIndex, offsetBy: index + 3)]
            if byte != 0 {
                closure(byte)
                history.append(byte)
            }
            window.append(contentsOf: history.suffix(length + 1))
            if window.count > windowSize {
                window.removeFirst(window.count - windowSize)
            }
            index += 4
        }
    }
}