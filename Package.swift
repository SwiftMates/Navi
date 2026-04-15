// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navi",
    platforms: [.iOS(.v17), .macOS(.v14)],
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
    ],
    swiftLanguageModes: [.v6]
)
