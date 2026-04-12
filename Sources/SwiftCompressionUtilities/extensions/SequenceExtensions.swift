
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