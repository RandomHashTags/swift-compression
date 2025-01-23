//
//  JSVariableMutability.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

public enum JSVariableMutability : Equatable, Sendable {
    case `var`
    case `let`
    case const

    @inlinable
    public var declarationCount : Int {
        switch self {
        case .var, .let: return 4
        case .const: return 6
        }
    }
}