
import SwiftCompressionUtilities

extension Snappy {
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) throws(CompressionError) -> UInt8? {
        return nil
    }
    public func compress(data: some Collection<UInt8>, reserveCapacity: Int) throws -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation
    }
}

/*
extension Snappy { // TODO: finish
    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(data: some Collection<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        var index = data.startIndex
        while index != data.endIndex {
            let (length, matchLength, offset) = longestMatch(data, from: index)
            if matchLength == 0 {
                let next = data.index(index, offsetBy: length)
                compressLiteral(data[index..<next], closure: closure)
                index = next
            } else {
                compressCopy(length: matchLength, offset: offset, closure: closure)
                index = data.index(index, offsetBy: matchLength)
            }
        }
        return nil
    }

    func longestMatch<C: Collection<UInt8>>(_ data: C, from startIndex: C.Index) -> (length: Int, matchLength: Int, offset: Int) {
        let maxLength = 60
        var longestMatchLength = 0
        var offset = 0

        var length = 0
        var index = startIndex
        while length < maxLength && index != data.endIndex {
            let starts = data.index(index, offsetBy: -min(length, windowSize), limitedBy: data.startIndex) ?? data.startIndex
            let longestMatch = longestCommonPrefix(data, index1: index, index2: starts)
            if length > longestMatchLength {
                longestMatchLength = longestMatch
                offset = data.distance(from: starts, to: index)
            }
            length += 1
            index = data.index(after: index)
        }
        return (length, longestMatchLength, offset: offset)
    }

    func longestCommonPrefix<C: Collection<UInt8>>(_ data: C, index1: C.Index, index2: C.Index) -> Int {
        var length = 0
        var index1 = index1
        var index2 = index2
        while index1 != data.endIndex && index2 != data.endIndex && data[index1] == data[index2] {
            length += 1
            index1 = data.index(after: index1)
            index2 = data.index(after: index2)
        }
        return length
    }
}

// MARK: Literal
extension Snappy {
    func compressLiteral<C: Collection<UInt8>>(_ data: C, closure: (UInt8) -> Void) {
        let count = data.count
        if count < 60 {
            closure(UInt8(count << 2))
        } else {
            closure(UInt8(60 << 2))
            closure(UInt8(count))
        }
        for value in data {
            closure(value)
        }
    }
}

// MARK: Copy
extension Snappy {
    func compressCopy(length: Int, offset: Int, closure: (UInt8) -> Void) {
        if length < 12 && offset < 2048 {
            let cmd = UInt8((offset >> 8) << 5 | (length - 4) << 2 | 1)
            closure(cmd)
            closure(UInt8(offset & 0xFF))
        } else {
            closure(UInt8((length - 1) << 2) | 2)
            closure(UInt8(offset & 0xFF))
            closure(UInt8((offset >> 8) & 0xFF))
        }
    }
}*/