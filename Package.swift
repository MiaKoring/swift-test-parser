// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-test-parser",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TestParser",
            targets: ["TestParser"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Zollerboy1/SwiftCommand.git",
            exact: "1.4.1"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "601.0.0"
        ),
        .package(
            url: "https://github.com/stackotter/swift-macro-toolkit",
            .upToNextMinor(from: "0.7.0")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TestParser",
            dependencies: [
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit")
            ]
        ),
        .testTarget(
            name: "TestParser-Tests",
            dependencies: ["TestParser"]
        ),
    ]
)
