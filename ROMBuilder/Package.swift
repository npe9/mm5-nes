// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ROMBuilder",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "ROMBuilder", targets: ["ROMBuilder"])
    ],
    dependencies: [
        .package(path: "../../Shared")
    ],
    targets: [
        .target(
            name: "ROMBuilder",
            dependencies: ["Shared"],
            path: ".",
            sources: ["ROMBuilder.swift", "Disassembler.swift", "iNESParser.swift", "ROMBuilderService.swift", "Types.swift"],
            resources: [
                .copy("Assembly")
            ]
        )
    ]
) 