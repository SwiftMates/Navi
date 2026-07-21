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
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0")
    ],
    targets: [
        .macro(
            name: "NaviMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/NaviMacrosImpl",
            sources: ["DestinationMacroImpl.swift"]
        ),
        .target(
            name: "Navi",
            dependencies: ["NaviMacrosImpl"],
            path: "Sources/Core",
            sources: [
                "Logger",
                "Navigation",
                "Macros/DestinationMacro.swift"
            ]
        ),
        .testTarget(
            name: "Navi-Tests",
            dependencies: [
                "Navi",
                "NaviMacrosImpl",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            path: "Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)
