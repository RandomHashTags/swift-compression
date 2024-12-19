//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 12/10/24.
//

extension Sequence where Element == UInt8 {
    func hexadecimal(separator: String = "") -> String {
        return map({ String(format: "%02X", $0) }).joined(separator: separator)
    }
}