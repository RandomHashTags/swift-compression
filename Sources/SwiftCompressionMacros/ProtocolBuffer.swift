//
//  ProtocolBuffer.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum ProtocolBuffer : DeclarationMacro {
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}