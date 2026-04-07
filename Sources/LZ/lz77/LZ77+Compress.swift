
import SwiftCompressionUtilities

extension LZ77 {
    /// Compress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to compress.
    ///   - closure: Logic to execute when a byte is compressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) -> UInt8? {
        let count = data.count
        var index = 0
        while index < count {
            let bufferEndIndex = min(index + bufferSize, count)
            guard index < bufferEndIndex else { break }
            let bufferCount = bufferEndIndex - index
            let bufferRange = data.index(data.startIndex, offsetBy: index)..<data.index(data.startIndex, offsetBy: bufferEndIndex)
            let buffer = data[bufferRange]
            let windowRange = data.index(data.startIndex, offsetBy: max(0, index - windowSize))..<data.index(data.startIndex, offsetBy: index)
            let window = data[windowRange]
            let windowCount = window.count
            var offset = 0
            var bestLength = 0
            for i in 0..<windowSize {
                var length = 0
                while length < bufferCount && window[positive: window.index(window.startIndex, offsetBy: i + length)] == buffer[length] {
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