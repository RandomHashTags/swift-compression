
import SwiftCompressionUtilities

extension CompressionTechnique {

    /// CSS compression techniques.
    public static let css = CSS()

    public struct CSS: Compressor {
        @inlinable
        public var algorithm: CompressionAlgorithm {
            .programmingLanguage(.css)
        }

        @inlinable
        public var quality: CompressionQuality {
            .lossy
        }
    }
}

// MARK: Compress
extension CompressionTechnique.CSS {
    public func compress(data: some Collection<UInt8>, reserveCapacity: Int) throws(CompressionError) -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation // TODO: support?
    }

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(data: some Sequence<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        return nil // TODO: support?
    }
}

// MARK: Minify
extension CompressionTechnique.CSS {
    /// Optimizes CSS code to make it suitable for production-only usage, which results in the minimum binary size required to represent the same code.
    /// 
    /// Optionally removes comments and unnecessary whitespace
    public func minify(data: some Collection<UInt8>, reserveCapacity: Int) -> [UInt8] {
        var index = 0
        let count = data.count
        var i = 0
        var result = [UInt8](repeating: 0, count: count)

        let space:UInt8 = 32
        let pound:UInt8 = 35
        let lineFeed:UInt8 = 10
        let carriageReturn:UInt8 = 13
        let asterisk:UInt8 = 42
        let horizontalTab:UInt8 = 9
        let period:UInt8 = 46
        let forwardSlash:UInt8 = 47
        let a:UInt8 = 97
        let c:UInt8 = 99
        let d:UInt8 = 100
        let l:UInt8 = 108
        let n:UInt8 = 110
        while data[i] == space || data[i] == horizontalTab || data[i] == lineFeed || data[i] == carriageReturn {
            i += 1
        }
        var calcDepth:UInt8 = 0
        while i < count {
            let char = data[i]
            switch char {
            case space,
                horizontalTab,
                lineFeed,
                carriageReturn:
                if calcDepth > 0 {
                    assign(byte: char, to: &index, in: &result)
                } else {
                    let next = data[i+1]
                    let iMinus1 = data[i-1]
                    if iMinus1.char.isLetter && (next == pound || next == period || next.char.isNumber || next.char.isLetter || iMinus1 == d && data[i-2] == n && data[i-3] == a) {
                        assign(byte: char, to: &index, in: &result)
                    }
                }
            case forwardSlash:
                if data[i+1] == asterisk {
                    i += 2
                    for j in i..<count {
                        if data[j] == asterisk && data[j+1] == forwardSlash {
                            i = j+1
                            break
                        }
                    }
                } else {
                    assign(byte: char, to: &index, in: &result)
                }
            case 40: // (
                if calcDepth > 0 || data[i-1] == c && data[i-2] == l && data[i-3] == a && data[i-4] == c { // in calc or calc( was found
                    calcDepth += 1
                }
                assign(byte: char, to: &index, in: &result)
            case 41: // )
                if calcDepth > 0 {
                    calcDepth -= 1
                }
                assign(byte: char, to: &index, in: &result)
            default:
                assign(byte: char, to: &index, in: &result)
            }
            i += 1
        }
        return .init(result[0..<index])
    }
    func assign(byte: UInt8, to index: inout Int, in data: inout [UInt8]) {
        data[index] = byte
        index += 1
    }
}

extension UInt8 {
    var char: Character {
        Character(UnicodeScalar(self))
    }
}