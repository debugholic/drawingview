// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DrawingView",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DrawingViewSwift",
            targets: ["DrawingViewSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pocketsvg/PocketSVG",
                 "2.7.0"..<"3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DrawingViewSwift",
            dependencies: ["PocketSVG"],
            path: "Sources"
        )
    ]
)
