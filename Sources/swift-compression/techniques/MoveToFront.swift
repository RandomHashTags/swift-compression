//
//  MoveToFront.swift
//
//
//  Created by Evan Anderson on 12/12/24.
//

import Foundation

// https://en.wikipedia.org/wiki/Move-to-front_transform
public enum MoveToFront { // TODO: finish
}

// MARK: Transform data
public extension MoveToFront {
    @inlinable
    static func transform(data: Data) -> Data {
        var sequence:[UInt8] = []
        sequence.reserveCapacity(data.count)
        var recentlyUsed:[UInt8] = [97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122]
        data.withUnsafeBytes { (p:UnsafeRawBufferPointer) in
            for i in 0..<p.count {
            }
        }
        return data
    }
}

extension MoveToFront {
    struct Record {
    }
}