//
//  HexadecimalTests.swift
//
//
//  Created by Evan Anderson on 12/10/24.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompressionUtilities

struct HexadecimalTests {

    #if canImport(Foundation)
    @Test func hexadecimal() {
        let string = "Wikipedia is a free, web-based, collaborative, multilingual encyclopedia project."
        let hex = string.utf8.hexadecimal()
        #expect(hex == "57696B697065646961206973206120667265652C207765622D62617365642C20636F6C6C61626F7261746976652C206D756C74696C696E6775616C20656E6379636C6F70656469612070726F6A6563742E")
    }
    #endif
    
}

#endif