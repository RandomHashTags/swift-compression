
import FrequencyTables

extension DNASingleBlockEncoding {
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ span: Span<UInt8>,
        configuration: CompressConfiguration
    ) -> ConcreteCompressionResult {
        let frequencyTable:[UInt8:Int] = buildFrequencyTable(span: span)
        var sortedFrequencyTable = frequencyTable.sorted(by: {
            guard $0.value != $1.value else { return $0.key < $1.key }
            return $0.value > $1.value
        })
        sortedFrequencyTable.removeLast()
        var sortedIndexes = [UInt8:Int]()
        var results = [UInt8:[UInt8]]()
        for (index, (key, _)) in sortedFrequencyTable.enumerated() {
            results[key] = []
            sortedIndexes[key] = index
        }
        for i in span.indices {
            let byte = span[i]
            let sortedIndex = sortedIndexes[byte] ?? sortedIndexes.count
            for i in 0..<sortedIndex {
                results[sortedFrequencyTable[i].key]!.append(0)
            }
            results[byte]?.append(1)
        }
        return results
    }
}