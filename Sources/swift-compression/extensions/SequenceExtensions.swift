//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 12/10/24.
//

#if canImport(Foundation)
import Foundation

extension Sequence where Element == UInt8 {
    @inlinable
    func hexadecimal(separator: String = "") -> String {
        return map({ String.init(format: "%02X", $0) }).joined(separator: separator)
    }
}
#endif

extension Collection {
    @inlinable
    func get(_ index: Index) -> Element? {
        return index < endIndex ? self[index] : nil
    }
}