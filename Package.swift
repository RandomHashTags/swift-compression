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
    // MARK: Products
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
    // MARK: Targets
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
        )
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