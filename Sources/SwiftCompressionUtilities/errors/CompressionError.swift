
/// SwiftCompression errors that can be thrown when compressing data.
public enum CompressionError: Error {
    case failedConversionOfStringToFoundationData
    case unsupportedOperation
}