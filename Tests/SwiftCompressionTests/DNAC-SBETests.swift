//
//  DNAC_SBETests.swift
//
//
//  Created by Evan Anderson on 12/18/24.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompression

struct DNAC_SBETests {
    @Test func compressDNAC_SBE() {
        let sequence:String = "TACTTGNCTAAAAGTACNATTGNCTAAGANTACACCGGCA"
        let data:[UInt8] = [UInt8](sequence.utf8)
        let result:CompressionResult<[UInt8]>? = CompressionTechnique.DNAC_SBE.compress(data: data)
    }
}

#endif