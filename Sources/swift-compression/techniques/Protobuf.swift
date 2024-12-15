//
//  Protobuf.swift
//
//
//  Created by Evan Anderson on 12/14/24.
//

import Foundation

// MARK: Protobuf
public extension CompressionTechnique {
    enum Protobuf {
        public enum WireType : Int {
            case varint
            case i64
            case len
            case sgroup
            case egroup
            case i32

            @inlinable
            func decode(dataType: DataType, index: inout Int, data: Data) -> Any? {
                switch self {
                    case .varint:
                        switch dataType {
                            case .bool:   return decodeBool(index: &index, data: data)
                            case .int32:  return decodeInt32(index: &index, data: data)
                            case .int64:  return decodeInt64(index: &index, data: data)
                            case .string: return decodeString(index: &index, data: data)
                            default:      return nil
                        }
                    default: return nil
                }
            }

            @inlinable
            func skip(index: inout Int, data: Data) {
                switch self {
                    case .varint: index += Int(decodeVarInt(index: &index, data: data))
                    case .i64:    index += 8
                    case .len:
                        let length:Int = Int(decodeVarInt(index: &index, data: data))
                        index += length
                    case .i32:    index += 4
                    default: break
                }
            }
        }

        public enum DataType {
            case any
            case bool
            case bytes
            case double
            case fixed32
            case fixed64
            case float
            case int32
            case int64
            indirect case map(key: DataType, value: DataType)
            indirect case optional(DataType)
            indirect case repeated(DataType)
            case reserved(index: Int)
            case reserved(fieldName: String)
            case sfixed32
            case sfixed64
            case sint32
            case sint64
            case string
            case structure(dataTypes: [DataType])
            case uint32
            case uint64
        }
    }
}

// MARK: ProtobufProtocol
public protocol ProtobufProtocol {
    static var values : [(String, CompressionTechnique.Protobuf.DataType)] { get }

    init()

    func value(forKey key: String) -> Any?
    mutating func setValue(forKey key: String, value: Any)

    func serialize(reserveCapacity: Int) -> Data
    static func deserialize(data: Data) -> Self
}

// MARK: Serialize
public extension ProtobufProtocol {
    @inlinable
    func serialize(reserveCapacity: Int = 1024) -> Data {
        var data:Data = Data()
        data.reserveCapacity(reserveCapacity)
        for (index, (key, dataType)) in Self.values.enumerated() {
            CompressionTechnique.Protobuf.encodeFieldTag(number: index+1, wireType: .varint, into: &data)
            if let value:Any = value(forKey: key) {
                switch dataType {
                    case .bool:   CompressionTechnique.Protobuf.encodeBool(value as! Bool, into: &data)
                    case .int32:  CompressionTechnique.Protobuf.encodeInt32(value as! Int32, into: &data)
                    case .int64:  CompressionTechnique.Protobuf.encodeInt64(value as! Int64, into: &data)
                    case .string: CompressionTechnique.Protobuf.encodeString(value as! String, into: &data)
                    default: break
                }
            }
        }
        return data
    }
}

extension CompressionTechnique.Protobuf {
    @inlinable
    static func encodeVarInt<T: FixedWidthInteger>(int: T, into data: inout Data) {
        var int:UInt64 = UInt64(int)
        while int > 0x7F {
            data.append(UInt8((int & 0x7F) | 0x80))
            int >>= 7
        }
        data.append(UInt8(int))
    }

    @inlinable
    static func encodeFieldTag(number: Int, wireType: CompressionTechnique.Protobuf.WireType, into data: inout Data) {
        let tag:Int = (number << 3) | wireType.rawValue
        encodeVarInt(int: tag, into: &data)
    }

    @inlinable
    static func encodeBool(_ bool: Bool, into data: inout Data) {
        encodeVarInt(int: bool ? 1 : 0, into: &data)
    }

    @inlinable
    static func encodeInt32(_ int: Int32, into data: inout Data) {
        encodeVarInt(int: int, into: &data)
    }

    @inlinable
    static func encodeInt64(_ int: Int64, into data: inout Data) {
        encodeVarInt(int: int, into: &data)
    }

    @inlinable
    static func encodeString(_ string: String, into data: inout Data) {
        guard let utf8:Data = string.data(using: .utf8) else { return }
        encodeVarInt(int: utf8.count, into: &data)
        data.append(utf8)
    }
}

// MARK: Deserialize
public extension ProtobufProtocol {
    static func deserialize(data: Data) -> Self {
        var value:Self = Self()
        var index:Int = 0
        while index < data.count {
            guard let (number, wireType):(Int, CompressionTechnique.Protobuf.WireType) = CompressionTechnique.Protobuf.decodeFieldTag(index: &index, data: data) else {
                break
            }
            let (key, dataType):(String, CompressionTechnique.Protobuf.DataType) = values[number-1]
            if let decoded:Any = wireType.decode(dataType: dataType, index: &index, data: data) {
                value.setValue(forKey: key, value: decoded)
            }
        }
        return value
    }
}

extension CompressionTechnique.Protobuf {
    @inlinable
    static func decodeVarInt(index: inout Int, data: Data) -> UInt64 {
        var result:UInt64 = 0, shift:UInt64 = 0
        while index < data.count {
            let byte:UInt8 = data[index]
            index += 1
            result |= UInt64(byte & 0x7F) << shift
            if (byte & 0x80) == 0 {
                break
            }
            shift += 7
        }
        return result
    }

    @inlinable
    static func decodeFieldTag(index: inout Int, data: Data) -> (Int, CompressionTechnique.Protobuf.WireType)? {
        let tag:UInt64 = decodeVarInt(index: &index, data: data)
        let number:Int = Int(tag >> 3)
        guard let wireType:CompressionTechnique.Protobuf.WireType = .init(rawValue: Int(tag & 0x07)) else {
            return nil
        }
        return (number, wireType)
    }

    @inlinable
    static func decodeLengthDelimited(index: inout Int, data: Data) -> Data {
        let length:Int = Int(decodeVarInt(index: &index, data: data))
        let bytes:Data = data[index..<index + length]
        index += length
        return bytes
    }
}

extension CompressionTechnique.Protobuf {
    @inlinable
    static func decodeString(index: inout Int, data: Data) -> String? {
        let bytes:Data = decodeLengthDelimited(index: &index, data: data)
        return String(data: bytes, encoding: .utf8)
    }

    @inlinable
    static func decodeBool(index: inout Int, data: Data) -> Bool {
        return Int32(decodeVarInt(index: &index, data: data)) != 0
    }
    
    @inlinable
    static func decodeInt32(index: inout Int, data: Data) -> Int32 {
        return Int32(decodeVarInt(index: &index, data: data))
    }

    @inlinable
    static func decodeInt64(index: inout Int, data: Data) -> Int64 {
        return Int64(decodeVarInt(index: &index, data: data))
    }
}