//
//  JSBody.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

public struct JSBody : Equatable, Sendable {
    public static let empty:JSBody = JSBody(declarations: [])
    public private(set) var declarations:[JSDeclaration]

    @inlinable
    public var string : String {
        var value:String = ""
        for decl in declarations {
            value += decl.string
        }
        return value
    }
}

// MARK: JSBody rename
// TODO: rename `true` to `!0` and `false` to `!1`
extension JSBody {
    public mutating func rename(exclude: Set<String> = []) {
        var alreadyRenamed:[String:String] = [:]
        rename(alreadyRenamed: &alreadyRenamed, exclude: exclude)
    }
    public mutating func rename(alreadyRenamed: inout [String:String], exclude: Set<String> = []) { // TODO: support scopes (global/local)
        let allowed:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for i in 0..<declarations.count {
            switch declarations[i] {
            case .function(var name, var parameters, var body):
                if name != nil {
                    name = rename(name: name!, allowed: allowed, alreadyRenamed: &alreadyRenamed)
                }
                for i in 0..<parameters.count {
                    let pName:String = parameters[i]
                    if let value:String = alreadyRenamed[pName] {
                        parameters[i] = value
                    } else {
                        parameters[i] = rename(name: pName, allowed: allowed, alreadyRenamed: &alreadyRenamed)
                    }
                }
                body.rename(alreadyRenamed: &alreadyRenamed, exclude: exclude)
                declarations[i] = .function(name: name, parameters: parameters, body: body)
                break
            case .declareVariables(let type, var names, var values):
                for j in 0..<names.count {
                    names[j] = rename(name: names[j], allowed: allowed, alreadyRenamed: &alreadyRenamed)
                }
                declarations[i] = .declareVariables(type: type, names: names, values: values)
                break
            case .referenceFunction(var variableName, var functionName, var parameters):
                if variableName != nil, let renamedVariableTo:String = alreadyRenamed[variableName!] {
                    variableName = renamedVariableTo
                }
                if let renamedTo:String = alreadyRenamed[functionName] {
                    functionName = renamedTo
                    for i in 0..<parameters.count {
                        let pName:String = parameters[i]
                        if let value:String = alreadyRenamed[pName] {
                            parameters[i] = value
                        } else {
                            parameters[i] = rename(name: pName, allowed: allowed, alreadyRenamed: &alreadyRenamed)
                        }
                    }
                }
                declarations[i] = .referenceFunction(variable: variableName, name: functionName, parameters: parameters)
                break
            case .referenceVariable(let name, let property):
                if let renamedTo:String = alreadyRenamed[name] {
                    declarations[i] = .referenceVariable(name: renamedTo, property: property)
                }
                break
            default:
                break
            }
        }
    }
    private func rename(name: String, allowed: String, alreadyRenamed: inout [String:String]) -> String {
        let newName:String = String(allowed.first(where: { alreadyRenamed.key(forValue: String($0)) == nil })!)
        alreadyRenamed[name] = newName
        return newName
    }
}

// MARK: Extensions
extension Dictionary where Value: Equatable {
    func key(forValue: Value) -> Key? {
        return first(where: { $1 == forValue })?.key
    }
}