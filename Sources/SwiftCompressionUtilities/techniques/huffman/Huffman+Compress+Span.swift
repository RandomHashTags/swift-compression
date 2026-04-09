
extension Huffman {
    public func compress(
        span: Span<UInt8>,
        configuration: CompressConfiguration
    ) throws(Never) -> ConcreteCompressionResult {
        return span.withUnsafeBufferPointer { buffer in
            return compress(buffer: buffer, closure: ({ frequencies, codes, root in
                var compressed:[UInt8] = [8]
                var vBitsInLastByte:UInt8 = 8
                if let (lastByte, validBitsInLastByte) = translate(buffer: buffer, codes: codes, closure: { compressed.append($0) }) {
                    compressed[0] = validBitsInLastByte
                    compressed.append(lastByte)
                    vBitsInLastByte = validBitsInLastByte
                }
                return .init(data: compressed, rootNode: root, frequencyTable: frequencies, validBitsInLastByte: vBitsInLastByte)
            }))
        }
    }
}