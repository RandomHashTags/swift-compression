
import SwiftCompressionUtilities

extension DNASingleBlockEncoding { // TODO: finish
    public func decompress(data: some Collection<UInt8>, closure: (UInt8) -> Void) throws(DecompressionError) {
    }

    /// Decompress a sequence of bytes using the DNA single block encoding technique.
    /// 
    /// - Parameters:
    ///   - data: Sequence of bytes to decompress.
    public static func decompress(data: [UInt8]) -> [UInt8] {
        return []
    }
}