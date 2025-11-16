
#if canImport(Foundation)
import Foundation

extension Sequence where Element == UInt8 {
    package func hexadecimal(separator: String = "") -> String {
        return map({ String.init(format: "%02X", $0) }).joined(separator: separator)
    }
}
#endif

extension Collection {
    /// - Returns: The element at the given index if within bounds. Otherwise `nil`.
    /// - Complexity: O(1).
    package func get(_ index: Index) -> Element? {
        return index < endIndex && index >= startIndex ? self[index] : nil
    }

    /// - Returns: The element at the given index if within bounds. Otherwise `nil`.
    /// - Complexity: O(1).
    package subscript(positive index: Index) -> Element? {
        return index < endIndex ? self[index] : nil
    }

    package subscript(_ index: some FixedWidthInteger) -> Element {
        get { self[self.index(startIndex, offsetBy: Int(index))] }
    }
}

extension Collection where Element == UInt8 {
    package func get(_ index: Int) -> Element? {
        guard let i = self.index(startIndex, offsetBy: index, limitedBy: endIndex) else { return nil }
        return self.get(i)
    }

    package func getPositive(_ index: Int) -> Element? {
        guard let i = self.index(startIndex, offsetBy: index, limitedBy: endIndex) else { return nil }
        return self[positive: i]
    }
}