
// MARK: Collection
extension Collection where Element == UInt8 {
    /// Compress a copy of this data using the specified technique(s).
    /// 
    /// - Returns: The `CompressionResult`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public func compressed(using technique: some Compressor) throws(CompressionError) -> CompressionResult<[UInt8]> {
        return try technique.compress(data: self)
    }

    /// Decompress the sequence of bytes using the specified technique(s).
    /// 
    /// - Returns: The decompressed bytes.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public func decompressed<T: Decompressor>(using technique: T) throws(DecompressionError) -> [UInt8] where T.DecompressClosureParameters == UInt8 {
        return try technique.decompress(data: [UInt8](self))
    }
}

// MARK: [UInt8]
extension Array where Element == UInt8 {
    /// Compress this data using the specified technique.
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    public mutating func compress(using technique: some Compressor) throws(CompressionError) -> Self {
        self = try technique.compress(data: self).data
        return self
    }

    /// Decompress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    public mutating func decompress<T: Decompressor>(using technique: T) throws(DecompressionError) -> Self where T.DecompressClosureParameters == UInt8 {
        self = try technique.decompress(data: self)
        return self
    }
}

// MARK: AsyncThrowingStream
extension Collection where Element == UInt8 {
    /// Decompress this data to a stream using the specified technique(s).
    /// 
    /// - Parameters:
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Returns: An `AsyncStream<UInt8>` that receives a decompressed byte.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func decompress<T: Decompressor>(
        using technique: T,
        bufferingPolicy limit: AsyncThrowingStream<UInt8, Error>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncThrowingStream<UInt8, Error> where T.DecompressClosureParameters == UInt8 {
        return AsyncThrowingStream { continuation in
            do {
                try technique.decompress(data: self, continuation: continuation)
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}

// MARK: Foundation
#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

#if canImport(FoundationEssentials) || canImport(Foundation)
extension Data {
    /// Compress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    public mutating func compress<T: Compressor>(using technique: T) throws(CompressionError) -> Self where T.CompressClosureParameters == UInt8 {
        self = try Data(technique.compress(data: [UInt8](self)).data)
        return self
    }

    /// Compress a copy of this data using the specified technique(s).
    /// 
    /// - Returns: The `CompressionResult`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public func compressed<T: Compressor>(using technique: T) throws(CompressionError) -> CompressionResult<[UInt8]> where T.CompressClosureParameters == UInt8 {
        return try technique.compress(data: [UInt8](self))
    }

    /// Decompress this data using the specified technique(s).
    /// 
    /// - Returns: The decompressed data.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public func decompressed<T: Decompressor>(using technique: T) throws(DecompressionError) -> Data where T.DecompressClosureParameters == UInt8 {
        return try Data(technique.decompress(data: [UInt8](self)))
    }
}
#endif

// MARK: StringProtocol
extension StringProtocol {
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public func compressed<T: Compressor>(using technique: T) throws(CompressionError) -> CompressionResult<[UInt8]> where T.CompressClosureParameters == UInt8 {
        let data:[UInt8] = [UInt8](self.utf8)
        return try data.compressed(using: technique)
    }

    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public mutating func compress<T: Compressor>(using technique: T) throws(CompressionError) where T.CompressClosureParameters == UInt8 {
        let result:[UInt8] = try compressed(using: technique).data
        self = Self(decoding: result, as: UTF8.self)
    }
}

#if canImport(FoundationEssentials) || canImport(Foundation)
extension StringProtocol {
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public func compressed<T: Compressor>(using technique: T, encoding: String.Encoding = .utf8) throws(CompressionError) -> CompressionResult<[UInt8]> where T.CompressClosureParameters == UInt8 {
        guard let data:Data = self.data(using: encoding) else { throw CompressionError.failedConversionOfStringToFoundationData }
        return try data.compressed(using: technique)
    }
}

extension String {
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    public mutating func compress<T: Compressor>(using technique: T, encoding: String.Encoding = .utf8) throws(CompressionError) where T.CompressClosureParameters == UInt8 {
        guard let data:Data = self.data(using: encoding) else { throw CompressionError.failedConversionOfStringToFoundationData }
        self = try String(data: Data(data.compressed(using: technique).data), encoding: encoding) ?? ""
    }
}
#endif