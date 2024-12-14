//
//  DataBuilderTests.swift
//
//
//  Created by Evan Anderson on 12/14/24.
//

import Foundation
import Testing
@testable import SwiftCompression

struct DataBuilderTests {
    @Test func dataBuilder() {
        var builder:CompressionTechnique.DataBuilder = CompressionTechnique.DataBuilder()
        builder.data.reserveCapacity(100)
        builder.write(bits: [true, false, true, false])
        builder.write(bits: [true, true, true, true, true])
        builder.finalize()
        #expect(builder.data == Data([175, 128]))
    }
}