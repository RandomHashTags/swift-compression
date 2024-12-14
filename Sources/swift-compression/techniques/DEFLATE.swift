//
//  DEFLATE.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import Foundation

public extension CompressionTechnique {
    enum Deflate { // TODO: finish
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

// MARK: Compress Data
public extension CompressionTechnique.Deflate {
    @inlinable
    static func compress(data: Data) -> CompressionResult {
        return CompressionResult(data: data)
    }
}

// MARK: Decompress Data
public extension CompressionTechnique.Deflate {
    @inlinable
    static func decompress(data: Data) -> Data {
        return data
    }
}