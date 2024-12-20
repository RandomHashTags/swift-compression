//
//  JSON.swift
//
//
//  Created by Evan Anderson on 12/14/24.
//

#if canImport(Foundation)
import Foundation
#endif

public extension CompressionTechnique {
    enum JSON { // TODO: finish
    }
}

#if canImport(Foundation)
// MARK: Compress encodable
public extension CompressionTechnique.JSON {
    @inlinable
    static func compress<T: Encodable>(encodable: T) -> CompressionResult<[UInt8]>? {
        guard let data:Data = try? JSONEncoder().encode(encodable) else { return nil }
        var compressed:[UInt8] = []
        compressed.reserveCapacity(data.count)
        guard let object:Any = try? JSONSerialization.jsonObject(with: data) else { return nil }
        let quotationMark:UInt8 = 34, comma:UInt8 = 44
        func encode(_ value: Any) {
            if var string:String = value as? String {
                compressed.append(comma)
                compressed.append(quotationMark)
                while !string.isEmpty {
                    let char:Character = string.removeFirst()
                    if let value:UInt8 = char.asciiValue {
                        compressed.append(value)
                    }
                }
                compressed.append(quotationMark)
            } else if let int:any FixedWidthInteger = value as? any FixedWidthInteger {
                compressed.append(comma)
                var builder:CompressionTechnique.DataBuilder = CompressionTechnique.DataBuilder()
                builder.write(bits: int.bits)
                builder.finalize()
                compressed.append(contentsOf: builder.data)
            } else if let dic:[String:Any] = value as? [String:Any] {
                compressed.append(comma)
                for value in dic.values {
                    encode(value)
                }
            } else if let array:[Any] = value as? [Any] {
                compressed.append(comma)
                for value in array {
                    encode(value)
                }
            } else if let bool:Bool = value as? Bool {
                compressed.append(comma)
                compressed.append(contentsOf: bool ? [] : [])
            }
        }
        if let dic:[String:Any] = object as? [String:Any] {
            for value in dic.values {
                encode(value)
            }
            compressed[0] = 91 // [
            compressed.append(93) // ]
        } else if let array:[Any] = object as? [Any] {
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
public extension CompressionTechnique.JSON {
    @inlinable
    static func compress<S: Sequence<UInt8>>(data: S) -> CompressionResult<[UInt8]>? {
        return nil
    }
}

// MARK: Decompress
public extension CompressionTechnique.JSON {
    @inlinable
    static func decompress(data: [UInt8]) -> [UInt8] {
        return data
    }
}