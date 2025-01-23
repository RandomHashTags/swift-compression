//
//  JSDeclaration.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

public indirect enum JSDeclaration : Equatable, Sendable {
    case literal(value: String)
    //case boolean(value: Bool)
    //case string(value: String)
    //case number(value: Int)

    case modifyVariable(name: String, property: String?, value: JSDeclaration)
    case referenceVariable(name: String, property: String?)
    case declareVariables(type: JSVariableMutability, names: [String], values: [JSDeclaration])

    case function(name: String?, parameters: [String], body: JSBody)
    case referenceFunction(variable: String?, name: String, parameters: [String])

    case loopFor(value: String, body: JSBody)
    case loopWhile(condition: String, body: JSBody)
    case branch(branch: JSBranch, else: [JSBranch]?)
    case `return`(value: JSDeclaration)

    @inlinable
    public var string : String {
        switch self {
        case .literal(let value): return value
        //case .number(let value): return "\(value)"

        case .modifyVariable(let name, let property, let value):
            return name + (property != nil ? "." + property! : "") + "=" + value.string
        case .referenceVariable(let name, let property):
            return name + (property != nil ? "." + property! : "")
        case .declareVariables(let type, let names, let values):
            var string:String = "\(type) "
            for i in 0..<names.count {
                if i != 0 {
                    string += ","
                }
                let targetValue:JSDeclaration = i < values.count ? values[i] : .literal(value: "")
                let declString:String = targetValue.string
                string += names[i] + (declString.count > 0 ? "=" + declString : "")
            }
            return string + ";"

        case .function(let name, let parameters, let body):
            return "function" + (name != nil ? " " + name! : "") + "(" + parameters.joined(separator: ",") + "){" + body.string + "}"
        case .referenceFunction(let variable, let name, let parameters):
            return (variable != nil ? variable! + "." : "") + name + "(" + parameters.joined(separator: ",") + ");"

        case .loopFor(let value, let body):
            return "for(" + value + "){" + body.string + "}"
        case .loopWhile(let condition, let body):
            return "while(" + condition + "){" + body.string + "}"
        case .branch(let branch, let elseBranches):
            var value:String = branch.string
            if let elseBranches {
                for branch in elseBranches {
                    value += "else " + branch.string
                }
                value.removeLast(5)
            }
            return value
        case .return(let value):
            return "return " + value.string
        }
    }
}

// MARK: Parse
extension JSDeclaration {
    public static func parse(offset: Int, _ string: String) -> Self {
        let start:String.Index = string.index(string.startIndex, offsetBy: offset), end:String.Index = string.index(before: string.endIndex)
        var i:Int = offset
        let value:String = String(string[start...])
        while i < value.count {
            if let secondIndex:String.Index = value.index(value.startIndex, offsetBy: 1, limitedBy: end), let thirdIndex:String.Index = value.index(secondIndex, offsetBy: 1, limitedBy: end) {
                var target:String = String(value[value.startIndex]) + String(value[secondIndex]) + String(value[thirdIndex])
                switch target {
                case "if(": return parseBranch(value)
                default:
                    if let fourthIndex:String.Index = value.index(thirdIndex, offsetBy: 1, limitedBy: end) {
                        target += String(value[fourthIndex])
                        switch target {
                        case "var ": return parseDeclareVariables(type: .var, value)
                        case "let ": return parseDeclareVariables(type: .let, value)
                        case "for(": return parseLoop(isFor: true, value)
                        default:
                            if let fifthIndex:String.Index = string.index(fourthIndex, offsetBy: 1, limitedBy: end), let sixthIndex:String.Index = string.index(fifthIndex, offsetBy: 1, limitedBy: end) {
                                target += String(string[fifthIndex]) + String(string[sixthIndex])
                                switch target {
                                case "const ": return parseDeclareVariables(type: .const, value)
                                case "while(": return parseLoop(isFor: false, value)
                                default:
                                    if let seventhIndex:String.Index = string.index(sixthIndex, offsetBy: 1, limitedBy: end) {
                                        target += String(string[seventhIndex])
                                        switch target {
                                        case "return ": return parseReturn(value)
                                        default:
                                            if let eigthIndex:String.Index = string.index(seventhIndex, offsetBy: 1, limitedBy: end), let ninethIndex:String.Index = string.index(eigthIndex, offsetBy: 1, limitedBy: end) {
                                                target += String(string[eigthIndex]) + String(string[ninethIndex])
                                                switch target {
                                                case "function ", "function(":
                                                    return parseFunction(value)
                                                default:
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            for j in i..<value.count {
                let targetIndex:String.Index = string.index(string.startIndex, offsetBy: j)
                switch string[targetIndex] {
                case "=":
                    break
                case "(":
                    break
                default:
                    break
                }
            }
            i = value.count
        }
        return .literal(value: value)
    }
}

// MARK: Parse Branch
extension JSDeclaration {
    static func parseBranch(_ string: String) -> Self {
        var conditionEnds:String.Index = string.startIndex
        var bodyIndex:Int = 1
        var bodyBegins:String.Index! = nil
        var bodyEnds:String.Index! = nil
        for i in 5..<string.count { // we can skip "if(x)"
            let targetIndex:String.Index = string.index(string.startIndex, offsetBy: i)
            if string[targetIndex] == "{" {
                if bodyBegins != nil {
                    bodyIndex += 1
                } else {
                    conditionEnds = string.index(string.startIndex, offsetBy: i-2)
                    bodyBegins = targetIndex
                }
            } else if string[targetIndex] == "}" {
                bodyIndex -= 1
                if bodyIndex == 0 {
                    bodyEnds = targetIndex
                    break
                }
            }
        }
        let condition:String = String(string[string.index(string.startIndex, offsetBy: 3)...conditionEnds])
        let body:JSBody = JSParser.parse(String(string[string.index(after: bodyBegins)..<bodyEnds]))
        return .branch(branch: JSBranch(condition: condition, body: body), else: [])
    }
}

// MARK: Parse Declare Variables
extension JSDeclaration {
    static func parseDeclareVariables(type: JSVariableMutability, _ string: String) -> Self {
        var variableNames:[String] = [""], variableValues:[JSDeclaration] = []
        var variableNameIndex:Int = 0
        var i:Int = type.declarationCount // we can skip "var " / "let " / "const "
        loop: while i < string.count {
            let targetIndex:String.Index = string.index(string.startIndex, offsetBy: i)
            switch string[targetIndex] {
            case ";":
                if variableNames.count != variableValues.count {
                    variableValues.append(.literal(value: ""))
                }
                break loop
            case ",":
                variableValues.append(.literal(value: ""))
                variableNameIndex += 1
                variableNames.append("")
            case "=":
                i += 1
                let bro:String.Index = string.index(after: targetIndex)
                loop2: for j in 0..<string.count {
                    let ends:String.Index = string.index(bro, offsetBy: j)
                    if string[ends] == ";" || string[ends] == "," {
                        variableValues.append(JSDeclaration.parse(offset: 0, String(string[bro..<ends])))
                        i += j
                        if string[ends] == "," {
                            variableNameIndex += 1
                            variableNames.append("")
                        }
                        break loop2
                    }
                }
            default:
                variableNames[variableNameIndex] += String(string[targetIndex])
            }
            i += 1
        }
        return .declareVariables(type: type, names: variableNames, values: variableValues)
    }
}

// MARK: Parse Function
extension JSDeclaration {
    static func parseFunction(_ string: String) -> Self {
        var name:String? = nil
        var parameters:[String] = []
        var body:JSBody = JSBody.empty
        var targetIndex:String.Index = string.index(string.startIndex, offsetBy: 8)
        switch string[targetIndex] {
        case " ":
            let nameStartIndex:String.Index = string.index(after: targetIndex)
            while targetIndex < string.endIndex {
                if string[targetIndex] == "(" {
                    name = String(string[nameStartIndex..<targetIndex])
                    break
                }
                targetIndex = string.index(after: targetIndex)
            }
        default:
            break
        }
        if string[targetIndex] == "(" && string[string.index(after: targetIndex)] != ")" {
            let parametersStartIndex:String.Index = string.index(after: targetIndex)
            targetIndex = parametersStartIndex
            while targetIndex < string.endIndex {
                if string[targetIndex] == ")" {
                    parameters = string[parametersStartIndex..<targetIndex].split(separator: ",").map({ String($0) })
                    break
                }
                targetIndex = string.index(after: targetIndex)
            }
        }
        while targetIndex < string.endIndex {
            if string[targetIndex] == "{" {
                var index:Int = 1
                targetIndex = string.index(after: targetIndex)
                let bodyStartIndex:String.Index = targetIndex
                while targetIndex < string.endIndex {
                    if string[targetIndex] == "{" {
                        index += 1
                    } else if string[targetIndex] == "}" {
                        index -= 1
                        if index == 0 {
                            body = JSParser.parse(String(string[bodyStartIndex..<targetIndex]))
                            break
                        }
                    }
                    targetIndex = string.index(after: targetIndex)
                }
                break
            }
            targetIndex = string.index(after: targetIndex)
        }
        return .function(name: name, parameters: parameters, body: body)
    }
}

// MARK: Parse Loop
extension JSDeclaration {
    static func parseLoop(isFor: Bool, _ string: String) -> Self {
        var condition:String = ""
        var body:JSBody = JSBody.empty
        for i in (isFor ? 4 : 6)..<string.count { // we can skip "for(" / "while("
            var targetIndex:String.Index = string.index(string.startIndex, offsetBy: i)
            if string[targetIndex] == "{" {
                condition = String(string[string.index(string.startIndex, offsetBy: 4)..<string.index(before: targetIndex)])
                var index:Int = 1
                let bodyStart:String.Index = string.index(after: targetIndex)
                for j in i+1..<string.count {
                    targetIndex = string.index(string.startIndex, offsetBy: j)
                    if string[targetIndex] == "}" {
                        index -= 1
                        if index == 0 {
                            body = JSParser.parse(String(string[bodyStart..<targetIndex]))
                            break
                        }
                    }
                }
                break
            }
        }
        return isFor ? .loopFor(value: condition, body: body) : .loopWhile(condition: condition, body: body)
    }
}

// MARK: Parse Return
extension JSDeclaration {
    static func parseReturn(_ string: String) -> Self {
        let value:JSDeclaration = JSDeclaration.parse(offset: 7, string) // we can skip "return "
        return .return(value: value)
    }
}