// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-compression",
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
