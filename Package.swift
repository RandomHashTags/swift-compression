// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "swift-compression",
    // MARK: Products
    products: [
        .library(name: "SwiftCompression", targets: ["SwiftCompression"]),
        .library(name: "SwiftCompressionUtilities", targets: ["SwiftCompressionUtilities"]),

        .library(name: "Brotli", targets: ["Brotli"]),
        .library(name: "SwiftCompressionDNA", targets: ["CompressionDNA"]),
        .library(name: "SwiftCompressionLZ", targets: ["CompressionLZ"]),
        .library(name: "FrequencyTables", targets: ["FrequencyTables"]),
        .library(name: "Huffman", targets: ["Huffman"]),
        .library(name: "RunLengthEncoding", targets: ["RunLengthEncoding"]),
        .library(name: "Snappy", targets: ["Snappy"]),
        .library(name: "Zlib", targets: ["Zlib"])
    ],
    // MARK: Traits
    traits: [
        .default(enabledTraits: [
            "Brotli",
            "Huffman",
            "LZ77",
            "RunLengthEncoding",
            "Snappy",
            "ZlibDeflate",
            "ZlibGzip",

            "AlgorithmAnyCompressor",
            "AlgorithmAnyDecompressor",

            "CollectionCompress", "CollectionDecompress",
            "FoundationCompress", "FoundationDecompress",
            "BrotliCompress", "BrotliDecompress",
            "HuffmanCompress", "HuffmanDecompress",
            "LZ77Compress", "LZ77Decompress",
            "SnappyCompress", "SnappyDecompress",
            "RunLengthEncodingCompress", "RunLengthEncodingDecompress",
            "ZlibDeflateCompress", "ZlibDeflateDecompress",
            "ZlibGzipCompress", "ZlibGzipDecompress",
        ]),

        .trait(name: "AlgorithmAnyCompressor", description: "Enables the `compressor: (any Compressor)?` computed property for `CompressionAlgorithm`."),
        .trait(name: "AlgorithmAnyDecompressor", description: "Enables the `decompressor: (any Decompressor)?` computed property for `CompressionAlgorithm`."),

        .trait(name: "CollectionCompress", enabledTraits: [
            "BrotliCompressCollection",
            "HuffmanCompressCollection",
            "LZ77CompressCollection",
            "RunLengthEncodingCompressCollection",
            "SnappyCompressCollection",
            "ZlibDeflateCompressCollection",
            "ZlibGzipCompressCollection",
        ]),

        .trait(name: "CollectionDecompress", enabledTraits: [
            "BrotliDecompressCollection",
            "HuffmanDecompressCollection",
            "LZ77DecompressCollection",
            "RunLengthEncodingDecompressCollection",
            "SnappyDecompressCollection",
            "ZlibDeflateDecompressCollection",
            "ZlibGzipDecompressCollection",
        ]),

        .trait(name: "FoundationCompress", enabledTraits: [
            "BrotliCompressFoundation",
            "HuffmanCompressFoundation",
            "LZ77CompressFoundation",
            "RunLengthEncodingCompressFoundation",
            "SnappyCompressFoundation",
            "ZlibDeflateCompressFoundation",
            "ZlibGzipCompressFoundation",
        ]),

        .trait(name: "FoundationDecompress", enabledTraits: [
            "BrotliDecompressFoundation",
            "HuffmanDecompressFoundation",
            "LZ77DecompressFoundation",
            "RunLengthEncodingDecompressFoundation",
            "SnappyDecompressFoundation",
            "ZlibDeflateDecompressFoundation",
            "ZlibGzipDecompressFoundation",
        ]),

        .trait(name: "Brotli", description: "Enables Brotli."),
        .trait(name: "BrotliCompress", description: "Enables Brotli compression for Span<UInt8>.", enabledTraits: ["Brotli"]),
        .trait(name: "BrotliCompressCollection", description: "Enables Brotli compression for some Collection<UInt8>.", enabledTraits: ["BrotliCompress"]),
        .trait(name: "BrotliCompressFoundation", description: "Enables Brotli compression for FoundationEssentials.Data.", enabledTraits: ["BrotliCompress"]),
        .trait(name: "BrotliDecompress", description: "Enables Brotli decompression for Span<UInt8>.", enabledTraits: ["Brotli"]),
        .trait(name: "BrotliDecompressCollection", description: "Enables Brotli decompression for some Collection<UInt8>.", enabledTraits: ["BrotliDecompress"]),
        .trait(name: "BrotliDecompressFoundation", description: "Enables Brotli decompression for FoundationEssentials.Data.", enabledTraits: ["BrotliDecompress"]),

        .trait(name: "Huffman", description: "Enables Huffman."),
        .trait(name: "HuffmanCompress", description: "Enables Huffman compression for Span<UInt8>.", enabledTraits: ["Huffman"]),
        .trait(name: "HuffmanCompressCollection", description: "Enables Huffman compression for some Collection<UInt8>.", enabledTraits: ["HuffmanCompress"]),
        .trait(name: "HuffmanCompressFoundation", description: "Enables Huffman compression for FoundationEssentials.Data.", enabledTraits: ["HuffmanCompress"]),
        .trait(name: "HuffmanDecompress", description: "Enables Huffman decompression for Span<UInt8>.", enabledTraits: ["Huffman"]),
        .trait(name: "HuffmanDecompressCollection", description: "Enables Huffman decompression for some Collection<UInt8>.", enabledTraits: ["HuffmanDecompress"]),
        .trait(name: "HuffmanDecompressFoundation", description: "Enables Huffman decompression for FoundationEssentials.Data.", enabledTraits: ["HuffmanDecompress"]),

        .trait(name: "LZ77", description: "Enables LZ77."),
        .trait(name: "LZ77Compress", description: "Enables LZ77 compression for Span<UInt8>.", enabledTraits: ["LZ77"]),
        .trait(name: "LZ77CompressCollection", description: "Enables LZ77 compression for some Collection<UInt8>.", enabledTraits: ["LZ77Compress"]),
        .trait(name: "LZ77CompressFoundation", description: "Enables LZ77 compression for FoundationEssentials.Data.", enabledTraits: ["LZ77Compress"]),
        .trait(name: "LZ77Decompress", description: "Enables LZ77 decompression for Span<UInt8>.", enabledTraits: ["LZ77"]),
        .trait(name: "LZ77DecompressCollection", description: "Enables LZ77 decompression for some Collection<UInt8>.", enabledTraits: ["LZ77Decompress"]),
        .trait(name: "LZ77DecompressFoundation", description: "Enables LZ77 decompression for FoundationEssentials.Data.", enabledTraits: ["LZ77Decompress"]),

        .trait(name: "RunLengthEncoding", description: "Enables RunLengthEncoding."),
        .trait(name: "RunLengthEncodingCompress", description: "Enables RunLengthEncoding compression for Span<UInt8>.", enabledTraits: ["RunLengthEncoding"]),
        .trait(name: "RunLengthEncodingCompressCollection", description: "Enables RunLengthEncoding compression for some Collection<UInt8>.", enabledTraits: ["RunLengthEncodingCompress"]),
        .trait(name: "RunLengthEncodingCompressFoundation", description: "Enables RunLengthEncoding compression for FoundationEssentials.Data.", enabledTraits: ["RunLengthEncodingCompress"]),
        .trait(name: "RunLengthEncodingDecompress", description: "Enables RunLengthEncoding decompression for Span<UInt8>.", enabledTraits: ["RunLengthEncoding"]),
        .trait(name: "RunLengthEncodingDecompressCollection", description: "Enables RunLengthEncoding decompression for some Collection<UInt8>.", enabledTraits: ["RunLengthEncodingDecompress"]),
        .trait(name: "RunLengthEncodingDecompressFoundation", description: "Enables RunLengthEncoding decompression for FoundationEssentials.Data.", enabledTraits: ["RunLengthEncodingDecompress"]),

        .trait(name: "Snappy", description: "Enables Snappy."),
        .trait(name: "SnappyCompress", description: "Enables Snappy compression for Span<UInt8>.", enabledTraits: ["Snappy"]),
        .trait(name: "SnappyCompressCollection", description: "Enables Snappy compression for some Collection<UInt8>.", enabledTraits: ["SnappyCompress"]),
        .trait(name: "SnappyCompressFoundation", description: "Enables Snappy compression for FoundationEssentials.Data.", enabledTraits: ["SnappyCompress"]),
        .trait(name: "SnappyDecompress", description: "Enables Snappy decompression for Span<UInt8>.", enabledTraits: ["Snappy"]),
        .trait(name: "SnappyDecompressCollection", description: "Enables Snappy decompression for some Collection<UInt8>.", enabledTraits: ["SnappyDecompress"]),
        .trait(name: "SnappyDecompressFoundation", description: "Enables Snappy decompression for FoundationEssentials.Data.", enabledTraits: ["SnappyDecompress"]),

        .trait(name: "ZlibDeflate", description: "Enables ZlibDeflate."),
        .trait(name: "ZlibDeflateCompress", description: "Enables ZlibDeflate compression for Span<UInt8>.", enabledTraits: ["ZlibDeflate"]),
        .trait(name: "ZlibDeflateCompressCollection", description: "Enables ZlibDeflate compression for some Collection<UInt8>.", enabledTraits: ["ZlibDeflateCompress"]),
        .trait(name: "ZlibDeflateCompressFoundation", description: "Enables ZlibDeflate compression for FoundationEssentials.Data.", enabledTraits: ["ZlibDeflateCompress"]),
        .trait(name: "ZlibDeflateDecompress", description: "Enables ZlibDeflate decompression for Span<UInt8>.", enabledTraits: ["ZlibDeflate"]),
        .trait(name: "ZlibDeflateDecompressCollection", description: "Enables ZlibDeflate decompression for some Collection<UInt8>.", enabledTraits: ["ZlibDeflateDecompress"]),
        .trait(name: "ZlibDeflateDecompressFoundation", description: "Enables ZlibDeflate decompression for FoundationEssentials.Data.", enabledTraits: ["ZlibDeflateDecompress"]),

        .trait(name: "ZlibGzip", description: "Enables ZlibGzip"),
        .trait(name: "ZlibGzipCompress", description: "Enables ZlibGzip compression for Span<UInt8>.", enabledTraits: ["ZlibGzip", "ZlibDeflateCompress"]),
        .trait(name: "ZlibGzipCompressCollection", description: "Enables ZlibGzip compression for some Collection<UInt8>.", enabledTraits: ["ZlibGzipCompress"]),
        .trait(name: "ZlibGzipCompressFoundation", description: "Enables ZlibGzip compression for FoundationEssentials.Data.", enabledTraits: ["ZlibGzipCompress"]),
        .trait(name: "ZlibGzipDecompress", description: "Enables ZlibGzip decompression for Span<UInt8>.", enabledTraits: ["ZlibGzip", "ZlibDeflateDecompress"]),
        .trait(name: "ZlibGzipDecompressCollection", description: "Enables ZlibGzip decompression for some Collection<UInt8>.", enabledTraits: ["ZlibGzipDecompress"]),
        .trait(name: "ZlibGzipDecompressFoundation", description: "Enables ZlibGzip decompression for FoundationEssentials.Data.", enabledTraits: ["ZlibGzipDecompress"]),
    ],

    // MARK: Targets
    targets: [
        .target(name: "ByteBuilder"),
        .target(name: "FrequencyTables"),
        .target(name: "SwiftCompressionUtilities"),

        .target(
            name: "SwiftCompression",
            dependencies: [
                "Brotli",
                "CompressionDNA",
                "CompressionLZ",
                "Huffman",
                "RunLengthEncoding",
                "Snappy",
                "Zlib",
                "SwiftCompressionUtilities",
            ]
        ),

        .systemLibrary(name: "BrotliShim"),
        .target(
            name: "Brotli",
            dependencies: [
                "SwiftCompressionUtilities",
                "BrotliShim"
            ],
            linkerSettings: [
                .unsafeFlags(["-lbrotlienc"], .when(traits: ["BrotliCompress"])),
                .unsafeFlags(["-lbrotlidec"], .when(traits: ["BrotliDecompress"]))
            ]
        ),
        .systemLibrary(name: "ZlibShim"),
        .target(
            name: "Zlib",
            dependencies: [
                "SwiftCompressionUtilities",
                "ZlibShim"
            ]
        ),

        .target(
            name: "CompressionDNA",
            dependencies: [
                "ByteBuilder",
                "FrequencyTables",
                "SwiftCompressionUtilities"
            ],
            path: "Sources/DNA"
        ),
        .target(
            name: "CompressionLZ",
            dependencies: [
                "ByteBuilder",
                "SwiftCompressionUtilities"
            ],
            path: "Sources/LZ"
        ),

        .target(
            name: "Huffman",
            dependencies: [
                "ByteBuilder",
                "SwiftCompressionUtilities"
            ]
        ),

        .target(
            name: "RunLengthEncoding",
            dependencies: [
                "SwiftCompressionUtilities"
            ]
        ),

        .systemLibrary(name: "SnappyShim"),
        .target(
            name: "Snappy",
            dependencies: [
                "ByteBuilder",
                "SwiftCompressionUtilities",
                "SnappyShim"
            ],
            linkerSettings: [
                .unsafeFlags(["-lsnappy"], .when(traits: ["Snappy"]))
            ]
        ),

        // MARK: Run
        .executableTarget(
            name: "Run",
            dependencies: [
                "SwiftCompression"
            ]
        ),

        // MARK: Unit tests
        .testTarget(name: "SwiftCompressionTests", dependencies: ["SwiftCompression"]),
        .testTarget(name: "BrotliTests", dependencies: ["Brotli"]),
        .testTarget(name: "DNATests", dependencies: ["CompressionDNA"]),
        .testTarget(name: "LZTests", dependencies: ["CompressionLZ"]),
        .testTarget(name: "SnappyTests", dependencies: ["Snappy"]),
        .testTarget(name: "ZlibTests", dependencies: ["Zlib"])
    ]
)

/*
// MARK: Add dynamic
//
// WARNING: MAKE SURE YOU HAVE "_DynamicX" SYMLINKS TO THE STATIC MODULES!
//
var dynamicProducts:[Product] = []
var dynamicTargets:[Target] = []
for target:Target in package.targets {
    if target.type == .regular || target.type == .executable {
        target.swiftSettings = [
            .define("STATIC")
        ]
        target.path = "Sources/" + target.name
        let dynamicName:String = "Dynamic" + target.name
        let dynamicProduct:Product, dynamicTarget:Target
        if target.type == .executable {
            dynamicTarget = .executableTarget(name: dynamicName)
            dynamicProduct = .executable(name: dynamicName, targets: [dynamicName])
        } else {
            dynamicTarget = .target(name: dynamicName)
            dynamicProduct = .library(name: dynamicName, type: .dynamic, targets: [dynamicName])
        }
        dynamicProducts.append(dynamicProduct)
        for dependency in target.dependencies {
            switch dependency {
                case .targetItem(let name, _):
                    dynamicTarget.dependencies.append(.target(name: "Dynamic" + name))
                case .productItem(let name, _, _, _):
                    dynamicTarget.dependencies.append(.target(name: "Dynamic" + name))
                case .byNameItem(let name, _):
                    dynamicTarget.dependencies.append(.target(name: "Dynamic" + name))
                @unknown default:
                    break
            }
        }
        dynamicTarget.path = "Sources/_" + dynamicName
        dynamicTarget.swiftSettings = [
            .define("DYNAMIC"),
            .unsafeFlags(["-enable-library-evolution"])
        ]
        dynamicTargets.append(dynamicTarget)
    }
}
package.products.append(contentsOf: dynamicProducts)
package.targets.append(contentsOf: dynamicTargets)*/