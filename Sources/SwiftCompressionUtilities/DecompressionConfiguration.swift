
public protocol DecompressionConfiguration: Sendable, ~Copyable {
    static var `default`: Self { get }
}