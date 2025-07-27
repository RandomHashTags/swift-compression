
import SwiftCompressionUtilities

#if canImport(Foundation)
import Foundation
#endif

extension CompressionTechnique {
    public enum JSON { // TODO: finish
    }
}

#if canImport(Foundation)
// MARK: Compress encodable
extension CompressionTechnique.JSON {
    @inlinable
    public static func compress(encodable: some Encodable) -> CompressionResult<[UInt8]>? {
        guard let data = try? JSONEncoder().encode(encodable) else { return nil }
        var compressed = [UInt8]()
        compressed.reserveCapacity(data.count)
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return nil }
        let quotationMark:UInt8 = 34
        let comma:UInt8 = 44
        func encode(_ value: Any) {
            if var string = value as? String {
                compressed.append(comma)
                compressed.append(quotationMark)
                while !string.isEmpty {
                    let char = string.removeFirst()
                    if let value = char.asciiValue {
                        compressed.append(value)
                    }
                }
                compressed.append(quotationMark)
            } else if let int = value as? any FixedWidthInteger {
                compressed.append(comma)
                var builder = CompressionTechnique.DataBuilder()
                builder.write(bits: int.bits)
                builder.finalize()
                compressed.append(contentsOf: builder.data)
            } else if let dic = value as? [String:Any] {
                compressed.append(comma)
                for value in dic.values {
                    encode(value)
                }
            } else if let array = value as? [Any] {
                compressed.append(comma)
                for value in array {
                    encode(value)
                }
            } else if let bool = value as? Bool {
                compressed.append(comma)
                compressed.append(contentsOf: bool ? [] : [])
            }
        }
        if let dic = object as? [String:Any] {
            for value in dic.values {
                encode(value)
            }
            compressed[0] = 91 // [
            compressed.append(93) // ]
        } else if let array = object as? [Any] {
            for value in array {
                encode(value)
            }
            compressed[0] = 91 // [
            compressed.append(93) // ]
        } else {
            return nil
        }
        return compress(data: compressed)
    }
}
#endif

// MARK: Compress
extension CompressionTechnique.JSON {
    @inlinable
    public static func compress(data: some Sequence<UInt8>) -> CompressionResult<[UInt8]>? {
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.JSON {
    @inlinable
    public static func decompress(data: [UInt8]) -> [UInt8] {
        return data
    }
}