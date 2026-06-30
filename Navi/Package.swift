// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navi",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "Navi",
            targets: ["Navi"]
        ),
    ],
    targets: [
        .target(
            name: "Navi"
        ),
        .testTarget(
            name: "NaviTests",
            dependencies: ["Navi"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
