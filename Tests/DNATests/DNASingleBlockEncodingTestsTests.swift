
import Testing
@testable import CompressionDNA
@testable import SwiftCompressionUtilities

struct DNASingleBlockEncodingTests {
    static let sequence = "TACTTGNCTAAAAGTACNATTGNCTAAGANTACACCGGCA"
    static let data = [UInt8](sequence.utf8)
    static let binary = DNASingleBlockEncoding().compress(data: data, configuration: .init())

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
        let (result, controlBits):([UInt8], [UInt8]) = DNASingleBlockEncoding.compressSBE(binaryData: Self.binary[65]!.prefix(7))
        #expect(result == [0, 1, 0])
        #expect(controlBits == [0])
    }
}