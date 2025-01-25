//
//  CompressionError.swift
//
//
//  Created by Evan Anderson on 12/26/24.
//

/// SwiftCompression errors that can be thrown when compressing data.
public enum CompressionError : Error {
    case failedConversionOfStringToFoundationData
    case unsupportedOperation
}