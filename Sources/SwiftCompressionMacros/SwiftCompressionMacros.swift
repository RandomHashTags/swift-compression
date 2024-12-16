//
//  SwiftCompressionMacros.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntaxMacros

// MARK: ErrorDiagnostic
struct DiagnosticMsg : DiagnosticMessage {
    let message:String
    let diagnosticID:MessageID
    let severity:DiagnosticSeverity

    init(id: String, message: String, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "SwiftCompressionMacros", id: id)
        self.severity = severity
    }
}
extension DiagnosticMsg : FixItMessage {
    var fixItID : MessageID { diagnosticID }
}


@main
struct SwiftCompressionMacros : CompilerPlugin {
    let providingMacros:[any Macro.Type] = [
    ]
}