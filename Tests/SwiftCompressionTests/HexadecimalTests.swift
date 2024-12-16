//
//  HexadecimalTests.swift
//
//
//  Created by Evan Anderson on 12/10/24.
//

#if swift(>=6.0)

import Foundation
import Testing
@testable import SwiftCompression

struct HexadecimalTests {
    @Test func hexadecimal() {
        let string:String = "Wikipedia is a free, web-based, collaborative, multilingual encyclopedia project."
        let data:Data = string.data(using: .utf8)!
        let hex:String = [UInt8](data).hexadecimal()
        #expect(hex == "57696B697065646961206973206120667265652C207765622D62617365642C20636F6C6C61626F7261746976652C206D756C74696C696E6775616C20656E6379636C6F70656469612070726F6A6563742E")
    }
}

#endif