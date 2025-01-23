// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-compression",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SwiftCompression",
            targets: ["SwiftCompression"]
        ),
        .library(
            name: "SwiftCompressionCSS",
            targets: ["CSS"]
        ),
        .library(
            name: "SwiftCompressionDNA",
            targets: ["DNA"]
        ),
        .library(
            name: "SwiftCompressionJavaScript",
            targets: ["JavaScript"]
        ),
        .library(
            name: "SwiftCompressionLZ",
            targets: ["LZ"]
        ),
        .library(
            name: "SwiftCompressionSnappy",
            targets: ["Snappy"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftCompressionUtilities"
        ),

        .target(
            name: "SwiftCompression",
            dependencies: [
                "SwiftCompressionUtilities",
                "CSS",
                "DNA",
                "JavaScript",
                "LZ",
                "Snappy"
            ]
        ),

        // MARK: Techniques
        .target(
            name: "CSS",
            dependencies: [
                "SwiftCompressionUtilities"
            ]
        ),
        .target(
            name: "DNA",
            dependencies: [
                "SwiftCompressionUtilities"
            ]
        ),
        .target(
            name: "JavaScript",
            dependencies: [
                "SwiftCompressionUtilities"
            ]
        ),
        .target(
            name: "LZ",
            dependencies: [
                "SwiftCompressionUtilities"
            ]
        ),
        .target(
            name: "Snappy",
            dependencies: [
                "SwiftCompressionUtilities"
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
        .testTarget(
            name: "SwiftCompressionTests",
            dependencies: ["SwiftCompression"]
        ),
        .testTarget(
            name: "CSSTests",
            dependencies: ["CSS"]
        ),
        .testTarget(
            name: "DNATests",
            dependencies: ["DNA"]
        ),
        .testTarget(
            name: "JavaScriptTests",
            dependencies: ["JavaScript"]
        ),
        .testTarget(
            name: "LZTests",
            dependencies: ["LZ"]
        ),
        .testTarget(
            name: "SnappyTests",
            dependencies: ["Snappy"]
        ),
    ]
)
