//
//  DNAC_SBETests.swift
//
//
//  Created by Evan Anderson on 12/18/24.
//

#if compiler(>=6.0)

import Testing
@testable import DNA
@testable import SwiftCompressionUtilities

struct DNASingleBlockEncodingTests {
    static let sequence:String = "TACTTGNCTAAAAGTACNATTGNCTAAGANTACACCGGCA"
    static let data:[UInt8] = [UInt8](sequence.utf8)
    static let binary:[UInt8:[UInt8]] = CompressionTechnique.DNASingleBlockEncoding.compressBinary(data: data)

    @Test func compressDNACSingleBlockEncodingPhase1() {
        #expect(Self.binary == [
            // A
            65: [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1],
            // T
            84: [1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
            // C
            67: [1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1],
            // G
            71: [1, 0, 1, 0, 1, 0, 1, 0, 1, 1]
        ])
    }

    @Test func compressDNACSingleBlockEncodingPhase2() {
        let (result, controlBits):([UInt8], [UInt8]) = CompressionTechnique.DNASingleBlockEncoding.compressSBE(binaryData: Self.binary[65]!.prefix(7))
        #expect(result == [0, 1, 0])
        #expect(controlBits == [0])
    }
}

#endif