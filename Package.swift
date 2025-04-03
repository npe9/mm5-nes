// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MMC5Dev",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MMC5Dev", targets: ["MMC5Dev"]),
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "ROMBuilder", targets: ["ROMBuilder"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Shared",
            dependencies: [],
            path: "Shared/Sources/Shared"
        ),
        .target(
            name: "ROMBuilder",
            dependencies: ["Shared"],
            path: "ROMBuilder/Sources/ROMBuilder",
            resources: [
                .copy("Assembly")
            ]
        ),
        .executableTarget(
            name: "MMC5Dev",
            dependencies: ["Shared", "ROMBuilder"],
            path: "MMC5Dev/Sources/MMC5Dev",
            resources: [
                .copy("Assets.xcassets")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        ),
        .testTarget(
            name: "MMC5DevUITests",
            dependencies: ["MMC5Dev"],
            path: "MMC5DevUITests",
            resources: [
                .copy("TestROM.nes")
            ]
        )
    ]
) 