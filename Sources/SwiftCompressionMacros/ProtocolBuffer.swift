//
//  ProtocolBuffer.swift
//
//
//  Created by Evan Anderson on 12/16/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum ProtocolBuffer : MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var values:String = "static let values:[(String, CompressionTechnique.Protobuf.DataType)] = ["
        var initializer:String = "init() {"
        var getVariable:String = "func value(forKey key: String) -> Any? {\nswitch key {\n"
        var setVariable:String = "mutating func setValue(forKey key: String, value: Any) {\nswitch key {\n"
        if let arguments:SyntaxChildren = node.arguments?.children(viewMode: .all) {
            for argument in arguments {
                if let labeled:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                    switch labeled.label!.text {
                        case "content":
                            let dictionary:DictionaryElementListSyntax = labeled.expression.dictionary!.content.as(DictionaryElementListSyntax.self)!
                            for element in dictionary {
                                let name:String = element.key.stringLiteral!.string, dataType:String = element.value.memberAccess!.declName.baseName.text
                                let cast:String, defaultValue:String
                                switch dataType {
                                    case "bool":   cast = "Bool"; defaultValue = "false"
                                    case "double": cast = "Double"; defaultValue = "0.0"
                                    case "float":  cast = "Float"; defaultValue = "0.0"
                                    case "int32":  cast = "Int32"; defaultValue = "0"
                                    case "int64":  cast = "Int64"; defaultValue = "0"
                                    case "string": cast = "String"; defaultValue = "\"\""
                                    case "uint32": cast = "UInt32"; defaultValue = "0"
                                    case "uint64": cast = "UInt64"; defaultValue = "0"
                                    default:       continue
                                }
                                values += "(\"" + name + "\",." + dataType + "),"
                                initializer += "\n" + name + " = " + defaultValue
                                getVariable += "case \"" + name + "\": return " + name + "\n"
                                setVariable += "case \"" + name + "\": " + name + " = value as! " + cast + "\n"
                            }
                        default:
                            break
                    }
                }
            }
        }
        values.removeLast()
        values += "]"
        initializer += "}"
        getVariable += "default: return nil\n}\n}"
        setVariable += "default: break\n}\n}"
        return [
            "\(raw: values)",
            "\(raw: initializer)",
            "\(raw: getVariable)",
            "\(raw: setVariable)"
        ]
    }
}