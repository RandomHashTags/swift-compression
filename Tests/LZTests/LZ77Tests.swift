
@testable import CompressionLZ
@testable import SwiftCompressionUtilities
import Testing

struct LZ77Tests {
    static let string:String = "abracadabra abracadabra"
    static let lz77 = LZ77<UInt16>(searchBufferSize: 4096, lookaheadBufferSize: 256)
    static let compressed = lz77.compress([UInt8](string.utf8), configuration: .init(reserveCapacity: 1024))

    /*@Test
    func decompressLZ77() throws(DecompressionError) {
        let result = Self.lz77.decompress(data: Self.compressed, configuration: .init(reserveCapacity: 1024))
        #expect(result == [UInt8](Self.string.utf8))
    }*/
}

// MARK: compress
extension LZ77Tests {
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
    func compressLZ77ToTokens(
        input: String,
        expectedOutput: [LZ77Token]
    ) {
        var output = [LZ77Token]()
        output.reserveCapacity(1024)
        Self.lz77.compress(span: input.utf8Span.span, closure: {
            output.append($0)
        })
        #expect(expectedOutput == output)
    }

    @Test(arguments: [
        ("aaaaaaaaaa", [
            0
        ]),
        /*("AABCAABCAABC", [
            0
        ]),
        ("abracadabra abracadabra", [
            0
        ]),*/
    ])
    func compressLZ77ToBits(
        input: String,
        expectedOutput: [UInt8]
    ) {
        let result:[UInt8] = Self.lz77.compress(input.utf8Span.span, configuration: .default)
        #expect(expectedOutput == result, "\(result.map({ String($0, radix: 2) })) != \(expectedOutput.map({ String($0, radix: 2) }))")
    }

    @Test(arguments: [
        (
            """
            I met a traveller from an antique land,
            Who said — "Two vast and trunkless legs of stone
            Stand in the desert Near them, on the sand,
            Half sunk a shattered visage lies, whose frown,
            And wrinkled lip, and sneer of cold command,
            Tell that its sculptor well those passions read
            Which yet survive, stamped on these lifeless things,
            The hand that mocked them, and the heart that fed;
            And on the pedestal, these words appear:
            My name is Ozymandias, King of Kings;
            Look on my Works, ye Mighty, and despair!
            Nothing beside remains. Round the decay
            Of that colossal Wreck, boundless and bare
            The lone and level sands stretch far away
            """,
            770
        ),
        (
            """
            I
            Half a league, half a league,
            Half a league onward,
            All in the valley of Death
            Rode the six hundred.
            “Forward, the Light Brigade!
            Charge for the guns!” he said.
            Into the valley of Death
            Rode the six hundred.

            II
            “Forward, the Light Brigade!”
            Was there a man dismayed?
            Not though the soldier knew
            Someone had blundered.
            Theirs not to make reply,
            Theirs not to reason why,
            Theirs but to do and die.
            Into the valley of Death
            Rode the six hundred.

            III
            Cannon to right of them,
            Cannon to left of them,
            Cannon in front of them
            Volleyed and thundered;
            Stormed at with shot and shell,
            Boldly they rode and well,
            Into the jaws of Death,
            Into the mouth of hell
            Rode the six hundred.

            IV
            Flashed all their sabres bare,
            Flashed as they turned in air
            Sabring the gunners there,
            Charging an army, while
            All the world wondered.
            Plunged in the battery-smoke
            Right through the line they broke;
            Cossack and Russian
            Reeled from the sabre stroke
            Shattered and sundered.
            Then they rode back, but not
            Not the six hundred.

            V
            Cannon to right of them,
            Cannon to left of them,
            Cannon behind them
            Volleyed and thundered;
            Stormed at with shot and shell,
            While horse and hero fell.
            They that had fought so well
            Came through the jaws of Death,
            Back from the mouth of hell,
            All that was left of them,
            Left of six hundred.

            VI
            When can their glory fade?
            O the wild charge they made!
            All the world wondered.
            Honour the charge they made!
            Honour the Light Brigade,
            Noble six hundred!
            """,
            1068
        )
    ])
    func compressLZ77Length(
        input: String,
        expectedLength: Int
    ) {
        let result:[UInt8] = Self.lz77.compress(input.utf8Span.span, configuration: .default)
        #expect(result.count == expectedLength)
    }
}

// MARK: Equatable
extension LZ77Token: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.offset == rhs.offset && lhs.length == rhs.length && lhs.char == rhs.char
    }
}

// MARK: CustomStringConvertible
extension LZ77Token: CustomStringConvertible {
    public var description: String {
        "(\(offset),\(length),\(char))"
    }
}