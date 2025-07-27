
import SwiftCompressionUtilities

extension CompressionTechnique {

    /// Swift compression techniques.
    public static let swift = SwiftLang()

    public struct SwiftLang: Compressor {
        @inlinable public var algorithm: CompressionAlgorithm { .programmingLanguage(.swift) }
        @inlinable public var quality: CompressionQuality { .lossy }
    }
}

// MARK: Compress
extension CompressionTechnique.SwiftLang {
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

/*
extension CompressionTechnique.SwiftLang { // TODO: support
    @inlinable
    public func compress(filePath: String) throws(CompressionError) -> String {
        return ""
    }
}*/
// MARK: Minify
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension CompressionTechnique.SwiftLang {
    /// Minifies Swift code to make it suitable for production-only usage, which results in the minimum binary size required to represent the same code.
    /// 
    /// Optionally removes documentation, comments, unnecessary whitespace and access control declarations, and unit tests
    /// 
    /// - Parameters:
    ///   - swiftSourceCode: Literal, valid, Swift code.
    @inlinable
    func minify<T: StringProtocol>(swiftSourceCode: T) throws -> T {
        // TODO: finish
        let accessControlInternal = try Regex(#"(internal\s+)"#)
        let documentation = try Regex(#"(\/\/\/.*)"#)
        let comments = try Regex(#"(\/\/.*)"#)
        
        var cleanup:[(Regex, String)] = try [
            (Regex(#"(\s*:\s*)"#), ":"),
            (Regex(#"(\s*{\s+)"#), "{"),
            (Regex(#"(\s*\(\s+)"#), "("),
            (Regex(#"(\s*\)\s+)"#), ")"),

            (Regex(#"(\s*{\s*get\s*})"#), "{get}"), // { get }
            (Regex(#"(\s*{\s*set\s*})"#), "{set}"), // { set }
            (Regex(#"(\s*{(\s*get\s*)\s*(\s*set\s*)\s*})"#), "{get set}"), // { get set }
            (Regex(#"(\s*{(\s*set\s*)\s*(\s*get\s*)\s*})"#), "{set get}") // { set get }
        ]
        let recursive:[Regex:String] = try [
            Regex(#"(\s*{\s+{)"#): "{{",
            Regex(#"(\s*}\s+})"#): "}}"
        ]
        let finalCleanup:[(Regex, String)] = try [
            (Regex(#"(}\s+fileprivate\s+var)"#), "};fileprivate var"),
            (Regex(#"(}\s+fileprivate\s+let)"#), "};fileprivate let"),
            (Regex(#"(}\s+open\s+var)"#), "};open var"),
            (Regex(#"(}\s+open\s+let)"#), "};open let"),
            (Regex(#"(}\s+package\s+var)"#), "};package var"),
            (Regex(#"(}\s+package\s+let)"#), "};package let"),
            (Regex(#"(}\s+private\s+var)"#), "};private var"),
            (Regex(#"(}\s+private\s+let)"#), "};private let"),
            (Regex(#"(}\s+public\s+var)"#), "};public var"),
            (Regex(#"(}\s+public\s+let)"#), "};public let"),
            (Regex(#"(}\s+var)"#), "};var"),
            (Regex(#"(}\s+let)"#), "};let"),
        ]
        cleanup.append(contentsOf: finalCleanup)

        //let stringLiterals:Regex = try Regex(#"(".+")"#)
        var result = String(swiftSourceCode)
        //let stringLiteralMatches = result.matches(of: stringLiterals)
        result.replace(accessControlInternal, with: "")
        result.replace(documentation, with: "")
        result.replace(comments, with: "")
        for (regex, replacement) in recursive {
            var matches = result.matches(of: regex)
            while !matches.isEmpty {
                for match in matches.reversed() {
                    result.replaceSubrange(match.range, with: replacement)
                }
                matches = result.matches(of: regex)
            }
        }
        for (regex, replacement) in cleanup {
            result.replace(regex, with: replacement)
        }
        while result.first?.isWhitespace == true {
            result.removeFirst()
        }
        return T(stringLiteral: result)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Regex: @retroactive Equatable {
    public static func == (lhs: Regex, rhs: Regex) -> Bool {
        false
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Regex: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
    }
}