//
//  JavaScript+Parse.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

// MARK: JSParser

// the endgame for this feature is to replace the minification logic with this, enabling more
// features like more effective compression, obfuscation, renaming declarations (further minifying the contents), and uglification
public struct JSParser { 
    public static func parse(_ string: String) -> JSBody {
        var declarations:[JSDeclaration] = []
        var offset:Int = 0
        var i:String.Index = string.startIndex
        while i < string.endIndex {
            let value:JSDeclaration = JSDeclaration.parse(offset: offset, string)
            declarations.append(value)
            let declString:String = value.string, declStringCount:Int = declString.count
            offset += declStringCount
            i = string.index(i, offsetBy: declStringCount, limitedBy: string.endIndex) ?? string.endIndex
        }
        return JSBody(declarations: declarations)
    }
}