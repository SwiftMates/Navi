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
        .package(url: "https://github.com/swiftlang/swift-syntax", .upToNextMajor(from: "603.0.0")),
        .package(url: "https://github.com/swiftlang/swift-format", from: "603.0.0"),
    ],
    targets: [
        .plugin(
            name: "SwiftFormatLint",
            capability: .buildTool(),
            path: "Plugins/SwiftFormatLint"
        ),
        .macro(
            name: "NaviMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/NaviMacrosPlugin",
            plugins: ["SwiftFormatLint"]
        ),
        .target(
            name: "Navi",
            dependencies: ["NaviMacrosPlugin"],
            path: "Sources/Core",
            sources: [
                "Logger",
                "Navigation",
                "Macros/DestinationMacro.swift"
            ],
            plugins: ["SwiftFormatLint"]
        ),
        .testTarget(
            name: "NaviTests",
            dependencies: [
                "Navi",
                "NaviMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax")
            ],
            path: "Tests",
            plugins: ["SwiftFormatLint"]
        )
    ],
    swiftLanguageModes: [.v6]
)
