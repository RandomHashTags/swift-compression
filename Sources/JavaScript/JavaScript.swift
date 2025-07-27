
import SwiftCompressionUtilities

extension CompressionTechnique {

    /// JavaScript compression techniques.
    public static let javascript:JavaScript = JavaScript()

    public struct JavaScript: Compressor {
        @inlinable public var algorithm: CompressionAlgorithm { .programmingLanguage(.javascript) }
        @inlinable public var quality: CompressionQuality { .lossy }
    }
}

// MARK: Compress
extension CompressionTechnique.JavaScript {
    @inlinable
    public func compress(data: some Collection<UInt8>, reserveCapacity: Int) throws(CompressionError) -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation // TODO: support?
    }

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress(data: some Sequence<UInt8>, closure: (UInt8) -> Void) -> UInt8? {
        return nil // TODO: support?
    }
}

// MARK: Minify
extension CompressionTechnique.JavaScript {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func minify(data: some Collection<UInt8>) -> [UInt8] { // TODO: optimize?
        var index = 0
        var keep = true
        let count = data.count
        var i = 0
        var result:[UInt8] = .init(repeating: 0, count: count)

        let space:UInt8 = 32
        let lineFeed:UInt8 = 10
        let carriageReturn:UInt8 = 13
        let asterisk:UInt8 = 42
        let horizontalTab:UInt8 = 9
        let forwardSlash:UInt8 = 47
        let a:UInt8 = 97
        let c:UInt8 = 99
        let e:UInt8 = 101
        let f:UInt8 = 102
        let iChar:UInt8 = 105
        let l:UInt8 = 108
        let n:UInt8 = 110
        let o:UInt8 = 111
        let p:UInt8 = 112
        let r:UInt8 = 114
        let s:UInt8 = 115
        let t:UInt8 = 116
        let u:UInt8 = 117
        let v:UInt8 = 118
        let w:UInt8 = 119
        let y:UInt8 = 121
        var char = data[i]
        while char == space || char == horizontalTab || char == lineFeed || char == carriageReturn {
            i += 1
            char = data[i]
        }
        while i < count {
            char = data[i]
            switch char {
            case space,
                horizontalTab,
                lineFeed,
                carriageReturn:
                let iPlus1 = data.getPositive(i+1)
                let iPlus2 = data.getPositive(i+2)
                let iPlus3 = data.getPositive(i+3)
                keep = iPlus1 == o && iPlus2 == f && iPlus3 == space // of
                    || iPlus1 == iChar && iPlus2 == n && iPlus3 == s && data.getPositive(i+4) == t && data.getPositive(i+5) == a && data.getPositive(i+6) == n && data.getPositive(i+7) == c && data.getPositive(i+8) == e && data.getPositive(i+9) == o && data.getPositive(i+10) == f && data.getPositive(i+11) == space // instanceof
                if !keep {
                    switch data.get(i-1) {
                    case r: // var
                        keep = data.get(i-2) == a && data.get(i-3) == v
                    case t: // let, const
                        let iMinus2 = data.get(i-2)
                        let iMinus3 = data.get(i-3)
                        keep = (iMinus2 == e && iMinus3 == l) || (iMinus2 == s && iMinus3 == n && data.get(i-4) == o && data.get(i-5) == c)
                    case n: // function, return
                        let iMinus2 = data.get(i-2)
                        let iMinus3 = data.get(i-3)
                        let iMinus4 = data.get(i-4)
                        let iMinus5 = data.get(i-5)
                        let iMinus6 = data.get(i-6)
                        keep = (iMinus2 == o && iMinus3 == iChar && iMinus4 == t && iMinus5 == c && iMinus6 == n && data.get(i-7) == u && data.get(i-8) == f)
                                || (iMinus2 == r && iMinus3 == u && iMinus4 == t && iMinus5 == e && iMinus6 == r)
                    case f: // of, typeof, instanceof
                        let iMinus3 = data.get(i-3)
                        let iMinus4 = data.get(i-4)
                        let iMinus5 = data.get(i-5)
                        let iMinus6 = data.get(i-6)
                        keep = data.get(i-2) == o && (iMinus3 == space
                                                || iMinus3 == e && iMinus4 == p && iMinus5 == y && iMinus6 == t
                                                || iMinus3 == e && iMinus4 == c && iMinus5 == n && iMinus6 == a && data.get(i-7) == t && data.get(i-8) == s && data.get(i-9) == n && data.get(i-10) == iChar
                                                )
                    case w: // new
                        keep = data.get(i-2) == e && data.get(i-3) == n
                    case e: // else if, case 0-9
                        let iMinus2 = data.get(i-2)
                        let iMinus3 = data.get(i-3)
                        let iMinus4 = data.get(i-4)
                        keep = (iMinus2 == s && iMinus3 == l && iMinus4 == e) && iPlus1 == iChar && iPlus2 == f
                            || (iMinus2 == s && iMinus3 == a && iMinus4 == c && (iPlus1 != nil ? iPlus1! >= 48 && iPlus1! <= 57 : false)) // 48 = "0"; 57 = "9"
                    default:
                        break
                    }
                }
            case forwardSlash:
                let iPlus1 = data.getPositive(i+1), isMultiline:Bool = iPlus1 == asterisk
                if iPlus1 == forwardSlash || isMultiline {
                    let endFunction:(UInt8?, Int) -> Bool, increment:Int
                    if isMultiline {
                        endFunction = { char, index in
                            return char == asterisk && data.getPositive(index+1) == forwardSlash
                        }
                        increment = 1
                    } else {
                        endFunction = { char, _ in
                            return char == horizontalTab || char == lineFeed || char == carriageReturn
                        }
                        increment = 0
                    }
                    i += 2
                    loop: for j in i..<count {
                        if endFunction(data.getPositive(j), j) {
                            i = j + increment
                            break loop
                        }
                    }
                    keep = false
                } else {
                    keep = true
                }
            case 96, // `
                34, // "
                39: // '
                keep = false
                result[index] = char
                index += 1
                i += 1
                for j in i..<count {
                    let value = data[j]
                    result[index] = value
                    index += 1
                    if value == char {
                        i = j
                        break
                    }
                }
            default:
                keep = true
            }
            if keep {
                result[index] = data[i]
                index += 1
            }
            i += 1
        }
        return .init(result[0..<index])
    }
}