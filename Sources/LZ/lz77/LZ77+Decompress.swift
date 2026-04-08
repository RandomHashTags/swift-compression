
import SwiftCompressionUtilities

extension LZ77: Decompressor {
    public typealias ConcreteDecompressionConfiguration = CompressConfiguration
    public typealias DecompressionResult = [UInt8]

    /// Decompress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte was decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> DecompressionResult {
        var result = DecompressionResult()
        decompress(data: data, closure: { result.append($0) })
        result.reserveCapacity(configuration.reserveCapacity)
        return result
    }

    /// Decompress a collection of bytes using the LZ77 technique.
    /// 
    /// - Parameters:
    ///   - data: Collection of bytes to decompress.
    ///   - closure: Logic to execute when a byte was decompressed.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    private func decompress(
        data: some Collection<UInt8>,
        closure: (UInt8) -> Void
    ) {
        let count = data.count
        var history = [UInt8]()
        var window = [UInt8]()
        var index = 0
        let bytesForOffset = T.bitWidth / 8
        let byteIndexOffset = bytesForOffset + 1
        while index < count {
            let length = Int(data[index + bytesForOffset])
            if length > 0 {
                let offset = parseOffset(data: data, index: index)
                let startIndex = window.count - Int(offset)
                let endIndex = min(startIndex + length, window.count)
                if startIndex < endIndex {
                    let bytes = window[startIndex..<endIndex]
                    for byte in bytes {
                        closure(byte)
                        history.append(byte)
                    }
                }
            }
            let byte = data[index + byteIndexOffset]
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

    func parseOffset(data: some Collection<UInt8>, index: Int) -> T {
        var byte = T()
        var offsetIndex = index
        for _ in 0...(T.bitWidth / 8)-1 {
            byte <<= 8
            byte += T(data[offsetIndex])
            offsetIndex += 1
        }
        return byte
    }
}