//
//  StringExtensions.swift
//
//
//  Created by Evan Anderson on 12/10/24.
//

extension StringProtocol {
    @inlinable
    var hexadecimal : UnfoldSequence<UInt8, Index> { // // https://stackoverflow.com/a/43360864
        sequence(state: startIndex) { startIndex in
            guard startIndex < endIndex else { return nil }
            let endIndex:String.Index = index(startIndex, offsetBy: 2, limitedBy: endIndex) ?? endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}