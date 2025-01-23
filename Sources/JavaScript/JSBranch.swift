//
//  JSBranch.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

public struct JSBranch : Equatable, Sendable {
    public let condition:String?
    public private(set) var body:JSBody

    @inlinable
    public var string : String {
        guard let condition:String = condition else { return "{" + body.string + "}" }
        return "if(" + condition + "){" + body.string + "}"
    }
}