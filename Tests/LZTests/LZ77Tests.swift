
@testable import CompressionLZ
@testable import SwiftCompressionUtilities
import Testing

struct LZ77Tests {
    static let string:String = "abracadabra abracadabra"
    static let lz77 = LZ77<UInt16>(searchBufferSize: 256, lookaheadBufferSize: 16)
    static let compressed = lz77.compress([UInt8](string.utf8), configuration: .init(reserveCapacity: 1024))

    @Test(arguments: [
        ("aaaaaaaaaa", [
            LZ77Token(offset: 0, length: 0, char: Character("a").asciiValue!),
            LZ77Token(offset: 1, length: 8, char: Character("a").asciiValue!)
        ]),
        ("AABCAABCAABC", [
            LZ77Token(offset: 0, length: 0, char: Character("A").asciiValue!),
            LZ77Token(offset: 1, length: 1, char: Character("B").asciiValue!),
            LZ77Token(offset: 0, length: 0, char: Character("C").asciiValue!),
            LZ77Token(offset: 4, length: 7, char: Character("C").asciiValue!),
        ]),
        ("abracadabra abracadabra", [
            LZ77Token(offset: 0, length: 0, char: Character("a").asciiValue!),
            LZ77Token(offset: 0, length: 0, char: Character("b").asciiValue!),
            LZ77Token(offset: 0, length: 0, char: Character("r").asciiValue!),
            LZ77Token(offset: 3, length: 1, char: Character("c").asciiValue!),
            LZ77Token(offset: 2, length: 1, char: Character("d").asciiValue!),
            LZ77Token(offset: 7, length: 4, char: Character(" ").asciiValue!),
            LZ77Token(offset: 12, length: 10, char: Character("a").asciiValue!),
        ]),
    ])
    func compressLZ77(
        input: String,
        expectedOutput: [LZ77Token]
    ) {
        let bytes = [UInt8](input.utf8)
        let output = bytes.withUnsafeBufferPointer({
            var compressedOutput = [LZ77Token]()
            compressedOutput.reserveCapacity(1024)
            Self.lz77.compress(buffer: $0, closure: {
                compressedOutput.append($0)
            })
            return compressedOutput
        })
        #expect(expectedOutput == output)
    }

    /*@Test
    func decompressLZ77() throws(DecompressionError) {
        let result = Self.lz77.decompress(data: Self.compressed, configuration: .init(reserveCapacity: 1024))
        #expect(result == [UInt8](Self.string.utf8))
    }*/
}

extension LZ77Token: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.offset == rhs.offset && lhs.length == rhs.length && lhs.char == rhs.char
    }
}

extension LZ77Token: CustomStringConvertible {
    public var description: String {
        "(\(offset),\(length),\(char))"
    }
}