
/// SwiftCompression errors that can be thrown when decompressing data.
public enum DecompressionError: Error {
    case malformedInput
    case unsupportedOperation(String = "")
}