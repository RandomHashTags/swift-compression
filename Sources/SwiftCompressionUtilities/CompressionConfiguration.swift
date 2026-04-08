
public protocol CompressionConfiguration: Sendable, ~Copyable {
    static var `default`: Self { get }
}