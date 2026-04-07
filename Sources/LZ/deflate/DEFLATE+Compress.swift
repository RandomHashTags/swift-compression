
import SwiftCompressionUtilities

extension Deflate {
    public static func compress(
        data: some Sequence<UInt8>,
        flags: borrowing Flags = .init(flags: 0),
        mtime: (UInt8, UInt8, UInt8, UInt8) = (0, 0, 0, 0),
        quality: borrowing Quality = .default,
        os: borrowing FileSystem = .unknown
    ) -> CompressionResult<[UInt8]>? {
        var result = [UInt8]()

        // gzip header
        result.append(contentsOf: [
            0x1F,                         // ID1
            0x8B,                         // ID2
            0x08,                         // CM (compression method; deflate=8)
            flags.bits,                   // FLG (flags)
            mtime.0.littleEndian,         // MTIME byte 1 (modification time)
            mtime.1.littleEndian,         // MTIME byte 2 (modification time)
            mtime.2.littleEndian,         // MTIME byte 3 (modification time)
            mtime.3.littleEndian,         // MTIME byte 4 (modification time)
            quality.rawValue.littleEndian // XFL (extra flags)
        ])
        // TODO: finish
        return .init(data: result)
    }
}