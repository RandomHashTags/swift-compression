// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "swift-compression",
    // MARK: Products
    products: [
        .library(
            name: "SwiftCompression",
            targets: ["SwiftCompression"]
        ),

        .library(
            name: "SwiftCompressionCSS",
            targets: ["CompressionCSS"]
        ),

        .library(
            name: "SwiftCompressionDNA",
            targets: ["CompressionDNA"]
        ),

        .library(
            name: "SwiftCompressionJavaScript",
            targets: ["CompressionJavaScript"]
        ),

        .library(
            name: "SwiftCompressionLZ",
            targets: ["CompressionLZ"]
        ),

        .library(
            name: "SwiftCompressionSnappy",
            targets: ["CompressionSnappy"]
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
                "CompressionCSS",
                "CompressionDNA",
                "CompressionJavaScript",
                "CompressionLZ",
                "CompressionSnappy"
            ]
        ),

        // MARK: Techniques
        .target(
            name: "CompressionCSS",
            dependencies: [
                "SwiftCompressionUtilities"
            ],
            path: "Sources/CSS"
        ),
        .target(
            name: "CompressionDNA",
            dependencies: [
                "SwiftCompressionUtilities"
            ],
            path: "Sources/DNA"
        ),
        .target(
            name: "CompressionJavaScript",
            dependencies: [
                "SwiftCompressionUtilities"
            ],
            path: "Sources/JavaScript"
        ),
        .target(
            name: "CompressionLZ",
            dependencies: [
                "SwiftCompressionUtilities"
            ],
            path: "Sources/LZ"
        ),
        .target(
            name: "CompressionSnappy",
            dependencies: [
                "SwiftCompressionUtilities"
            ],
            path: "Sources/Snappy"
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
            dependencies: ["CompressionCSS"]
        ),
        .testTarget(
            name: "DNATests",
            dependencies: ["CompressionDNA"]
        ),
        .testTarget(
            name: "JavaScriptTests",
            dependencies: ["CompressionJavaScript"]
        ),
        .testTarget(
            name: "LZTests",
            dependencies: ["CompressionLZ"]
        ),
        .testTarget(
            name: "SnappyTests",
            dependencies: ["CompressionSnappy"]
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