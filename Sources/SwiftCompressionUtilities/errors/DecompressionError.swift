//
//  DecompressionError.swift
//
//
//  Created by Evan Anderson on 12/26/24.
//

/// SwiftCompression errors that can be thrown when decompressing data.
public enum DecompressionError : Error {
    case malformedInput
    case unsupportedOperation
}