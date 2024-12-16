//
//  ProtobufTests.swift
//
//
//  Created by Evan Anderson on 12/14/24.
//

#if compiler(>=6.0)

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

@ProtocolBuffer(content: [
    "id" : .int32,
    "name" : .string,
    "isTrue" : .bool
])
struct ProtobufExample1 : Hashable, ProtobufProtocol {
    var id:Int32
    var name:String
    var isTrue:Bool
    
    init(id: Int32, name: String, isTrue: Bool) {
        self.id = id
        self.name = name
        self.isTrue = isTrue
    }
}

#endif