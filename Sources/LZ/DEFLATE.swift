//
//  DEFLATE.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import SwiftCompressionUtilities

extension CompressionTechnique {
    /// The Deflate compression technique.
    /// 
    /// https://en.wikipedia.org/wiki/Deflate
    public enum Deflate { // TODO: finish
        struct Block {
            let lastBlock:Bool
            let encoding:(Bool, Bool)

            enum Encoding : Equatable {
                case stored
                case staticHuffman
                case dynamicHuffman
                case reserved

                init(_ binary: (Bool, Bool)) {
                    switch binary {
                    case (false, false): self = .stored
                    case (false, true):  self = .staticHuffman
                    case (true, false):  self = .dynamicHuffman
                    case (true, true):   self = .reserved
                    }
                }

                var binary : (Bool, Bool) {
                    switch self {
                    case .stored: return (false, false)
                    case .staticHuffman: return (false, true)
                    case .dynamicHuffman: return (true, false)
                    case .reserved: return (true, true)
                    }
                }
            }
        }
    }
}

// MARK: Compress
extension CompressionTechnique.Deflate {
    @inlinable
    public static func compress<T: Sequence<UInt8>>(
        data: T
    ) -> CompressionResult<[UInt8]>? {
        return nil
    }
}

// MARK: Decompress
extension CompressionTechnique.Deflate {
    @inlinable
    public static func decompress(data: [UInt8]) -> [UInt8] {
        return data
    }
}