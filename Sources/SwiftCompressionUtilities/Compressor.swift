
/// Any type conforming to this protocol indicates it compresses data.
public protocol Compressor: AnyCompressor, ~Copyable {
    associatedtype ConcreteCompressionConfiguration:CompressionConfiguration
    associatedtype ConcreteCompressionResult = [UInt8]
    associatedtype ConcreteCompressionError:Error = CompressionError

    /// Compresses a span of bytes.
    /// 
    /// - Parameters:
    ///   - data: The span of bytes to compress.
    ///   - configuration: Additional values necessary to compress the provided data.
    /// 
    /// - Returns: `ConcreteCompressionResult`; usually, but not guaranteed, an array of bytes (`[UInt8]`).
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    func compress(
        _ span: Span<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult
}

// MARK: Array
extension Compressor {
    /// Compresses an array of bytes.
    /// 
    /// - Parameters:
    ///   - array: The array of bytes to compress.
    ///   - configuration: Additional values necessary to compress the provided data.
    /// 
    /// - Returns: `ConcreteCompressionResult`; usually, but not guaranteed, an array of bytes (`[UInt8]`).
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ array: [UInt8],
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult {
        return try compress(array.span, configuration: configuration)
    }
}

// MARK: ArraySlice
extension Compressor {
    /// Compresses an array slice of bytes.
    /// 
    /// - Parameters:
    ///   - slice: The array slice of bytes to compress.
    ///   - configuration: Additional values necessary to compress the provided data.
    /// 
    /// - Returns: `ConcreteCompressionResult`; usually, but not guaranteed, an array of bytes (`[UInt8]`).
    @available(macOS 10.14.4, iOS 12.2, watchOS 5.2, tvOS 12.2, visionOS 1.0, *)
    public func compress(
        _ slice: ArraySlice<UInt8>,
        configuration: ConcreteCompressionConfiguration
    ) throws(ConcreteCompressionError) -> ConcreteCompressionResult {
        return try compress(slice.span, configuration: configuration)
    }
}