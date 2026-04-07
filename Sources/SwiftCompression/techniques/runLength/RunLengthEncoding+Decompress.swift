
extension RunLengthEncoding {
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func decompress(data: some Collection<UInt8>, closure: (UInt8) -> Void) {
        let count = data.count
        var index = 0
        var run:UInt8 = 0
        var character:UInt8 = 0
        while index < count {
            run = data[index]
            if run > 191 {
                run -= 191
                character = data[index+1]
                index += 2
                for _ in 0..<run {
                    closure(character)
                }
            } else {
                index += 1
                closure(run)
            }
        }
    }
}