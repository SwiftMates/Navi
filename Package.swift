// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Navi",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Navi",
            targets: ["Navi"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", .upToNextMajor(from: "603.0.0"))
    ],
    targets: [
        .macro(
            name: "NaviMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/NaviMacrosPlugin"
        ),
        .target(
            name: "Navi",
            dependencies: ["NaviMacrosPlugin"],
            path: "Sources/Core",
            sources: [
                "Logger",
                "Navigation",
                "Macros/DestinationMacro.swift"
            ]
        ),
        .testTarget(
            name: "NaviTests",
            dependencies: [
                "Navi",
                "NaviMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            path: "Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)
