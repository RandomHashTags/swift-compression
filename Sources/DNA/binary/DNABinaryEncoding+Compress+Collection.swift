
import SwiftCompressionUtilities

extension DNABinaryEncoding {
    public func compress(
        data: some Collection<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) -> ConcreteCompressionResult {
        var result = ConcreteCompressionResult()
        let validBitsInLastByte = data.withContiguousStorageIfAvailable {
            compress(buffer: $0, closure: { result.append($0) })
        }
        return result
    }
}