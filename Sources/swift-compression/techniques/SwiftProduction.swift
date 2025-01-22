//
//  SwiftProduction.swift
//
//
//  Created by Evan Anderson on 1/22/25.
//

extension CompressionTechnique {

    /// The Swift Production compression technique.
    /// 
    /// Optimizes Swift code to make it suitable for production-only usage, which results in the minimum binary size required to represent the same code.
    /// 
    /// Optionally removes:
    ///   - documentation
    ///   - comments
    ///   - unnecessary whitespace
    ///   - unnecessary access control declarations
    ///   - unit tests
    public static let swiftProduction:SwiftProduction = SwiftProduction()

    public struct SwiftProduction : Compressor {
        @inlinable public var algorithm : CompressionAlgorithm { .swiftProduction }
        @inlinable public var quality : CompressionQuality { .lossy }
    }
}

// MARK: Compress
extension CompressionTechnique.SwiftProduction {
    @inlinable
    public func compress<C: Collection<UInt8>>(data: C, reserveCapacity: Int) throws -> CompressionResult<[UInt8]> {
        throw CompressionError.unsupportedOperation
    }

    /// - Parameters:
    ///   - data: The sequence of bytes to compress.
    ///   - minRun: The minimum run count required to compress identical sequential bytes.
    ///   - closure: The logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    @inlinable
    public func compress<S: Sequence<UInt8>>(data: S, closure: (UInt8) -> Void) -> UInt8? {
        return nil
    }
}

/*
extension CompressionTechnique.SwiftProduction { // TODO: support
    @inlinable
    public func compress(filePath: String) throws -> String {
        return ""
    }
}*/
extension CompressionTechnique.SwiftProduction {
    /// Compress literal Swift code.
    @inlinable
    /*public */func compress<T: StringProtocol>(swiftSourceCode: T) throws -> T {
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
                for match in matches {
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