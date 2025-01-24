//
//  SwiftProduction.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

import SwiftCompressionUtilities

extension CompressionTechnique {

    /// Swift compression techniques.
    public static let swift:SwiftLang = SwiftLang()

    public struct SwiftLang : Compressor {
        @inlinable public var algorithm : CompressionAlgorithm { .programmingLanguage(.swift) }
        @inlinable public var quality : CompressionQuality { .lossy }
    }
}

// MARK: Compress
extension CompressionTechnique.SwiftLang {
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, reserveCapacity: Int) throws -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation // TODO: support?
    }

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<S: Sequence<UInt8>>(data: S, closure: (UInt8) -> Void) -> UInt8? {
        return nil // TODO: support?
    }
}

/*
extension CompressionTechnique.SwiftProduction { // TODO: support
    @inlinable
    public func compress(filePath: String) throws -> String {
        return ""
    }
}*/
// MARK: Minify
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
        let accessControlInternal:Regex = try Regex(#"(internal\s+)"#)
        let documentation:Regex = try Regex(#"(\/\/\/.*)"#)
        let comments:Regex = try Regex(#"(\/\/.*)"#)
        
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
            Regex(#"(\s*{\s+{)"#) : "{{",
            Regex(#"(\s*}\s+})"#) : "}}"
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

        let stringLiterals:Regex = try Regex(#"(".+")"#)
        var result:String = String(swiftSourceCode)
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

extension Regex : Hashable {
    public static func == (lhs: Regex, rhs: Regex) -> Bool {
        false
    }

    public func hash(into hasher: inout Hasher) {
    }
}