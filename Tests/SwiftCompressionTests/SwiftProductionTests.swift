//
//  SwiftProductionTests.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

#if compiler(>=6.0)

import Testing
@testable import SwiftCompression

struct SwiftProductionTests {

    @Test
    func swiftCode() throws {
        let code:String = """
        //
        //  AnyCompressor.swift
        //
        //
        //  Created by Evan Anderson on 12/26/24.
        //

        // MARK: AnyCompressor
        public protocol AnyCompressor : Sendable {
            /// Compression algorithm this compressor uses.
            public var algorithm : CompressionAlgorithm { get }

            /// Quality of the compressed data.
            var quality : CompressionQuality { get }
        }
        """
        let result:String = try CompressionTechnique.swiftProduction.compress(swiftSourceCode: code)
        #expect(result == "public protocol AnyCompressor:Sendable{public var algorithm:CompressionAlgorithm{get};var quality:CompressionQuality{get}}")
    }
}

#endif