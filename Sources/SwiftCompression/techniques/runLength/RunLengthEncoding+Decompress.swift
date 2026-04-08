
import SwiftCompressionUtilities

extension RunLengthEncoding: Decompressor {
    public typealias ConcreteDecompressionConfiguration = CompressConfiguration
    public typealias DecompressionResult = [UInt8]

    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(
        data: some Collection<UInt8>,
        configuration: ConcreteDecompressionConfiguration
    ) -> DecompressionResult {
        var result = DecompressionResult()
        decompress(data: data, closure: { result.append($0) })
        return result
    }

    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    private func decompress(data: some Collection<UInt8>, closure: (UInt8) -> Void) {
        let count = data.count
        var index = 0
        var run:UInt8 = 0
        var character:UInt8 = 0
        while index < count {
            run = data[index]
            if run > 191 {
                run -= 191
                character = data[index+1]
                index += 2
                for _ in 0..<run {
                    closure(character)
                }
            } else {
                index += 1
                closure(run)
            }
        }
    }
}