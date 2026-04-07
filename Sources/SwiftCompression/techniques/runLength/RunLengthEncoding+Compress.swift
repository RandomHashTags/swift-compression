
extension RunLengthEncoding {
    public func compressClosure(closure: @escaping (UInt8) -> Void) -> (CompressClosureParameters) -> Void {
        if alwaysIncludeRunCount {
            return { (arg) in
                let (run, runByte) = arg
                closure(UInt8(191 + run))
                closure(runByte)
            }
        } else {
            return { (arg) in
                let (run, runByte) = arg
                if runByte <= 191 && run < minRun {
                    for byte in Array(repeating: runByte, count: run) {
                        closure(byte)
                    }
                } else {
                    closure(UInt8(191 + run))
                    closure(runByte)
                }
            }
        }
    }

    /// - Parameters:
    ///   - data: Sequence of bytes to compress.
    ///   - minRun: Minimum run count required to compress identical sequential bytes.
    ///   - closure: Logic to execute for a run.
    /// - Complexity: O(_n_) where _n_ is the length of `data`.
    public func compress(data: some Sequence<UInt8>, closure: (CompressClosureParameters) -> Void) -> UInt8? {
        var run = 0
        var runByte:UInt8? = nil
        data.withContiguousStorageIfAvailable { p in
            for index in 0..<p.count {
                let byte = p[index]
                if runByte == byte {
                    if run == 64 {
                        closure((run, runByte!))
                        run = 1
                    } else {
                        run += 1
                    }
                } else {
                    if let runByte {
                        closure((run, runByte))
                    }
                    runByte = byte
                    run = 1
                }
            }
        }
        if let runByte {
            closure((run, runByte))
        }
        return nil
    }
}