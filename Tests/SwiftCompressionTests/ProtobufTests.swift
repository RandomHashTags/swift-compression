//
//  ProtobufTests.swift
//
//
//  Created by Evan Anderson on 12/14/24.
//

#if compiler(>=6.0)

import Foundation
import Testing
@testable import SwiftCompression

struct ProtobufTests {
    @Test func protobuf() {
        let example1:ProtobufExample1 = ProtobufExample1(id: 9, name: "HOOPLA", isTrue: true)
        let data:[UInt8] = example1.serialize()

        let result:ProtobufExample1 = ProtobufExample1.deserialize(data: data)
        #expect(example1 == result)
        //print("protobuf;example1;serialized=\([UInt8](data))")
    }
}

struct ProtobufExample1 : Hashable, ProtobufProtocol {
    static let values:[(String, CompressionTechnique.Protobuf.DataType)] = [("id", .int32), ("name", .string), ("isTrue", .bool)]

    var id:Int32
    var name:String
    var isTrue:Bool

    init() {
        id = -1
        name = ""
        isTrue = false
    }
    init(id: Int32, name: String, isTrue: Bool) {
        self.id = id
        self.name = name
        self.isTrue = isTrue
    }

    func value(forKey key: String) -> Any? {
        switch key {
            case "id": return id
            case "name": return name
            case "isTrue": return isTrue
            default: return nil
        }
    }

    mutating func setValue(forKey key: String, value: Any) {
        switch key {
            case "id": id = value as! Int32
            case "name": name = value as! String
            case "isTrue": isTrue = value as! Bool
            default: break
        }
    }
}

#endif