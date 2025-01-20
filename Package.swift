// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-compression",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "SwiftCompression",
            targets: ["SwiftCompression"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftCompression",
            path: "Sources/swift-compression"
        ),
        .testTarget(
            name: "SwiftCompressionTests",
            dependencies: ["SwiftCompression"]
        ),
    ]
)
