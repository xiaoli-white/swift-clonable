// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SwiftClonable",
    products: [
        .library(
            name: "SwiftClonable",
            targets: ["SwiftClonable"]
        ),
        .executable(
            name: "SwiftClonableClient",
            targets: ["SwiftClonableClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "SwiftClonableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftClonable",
            dependencies: [
                "SwiftClonableMacros",
            ]),
        .executableTarget(name: "SwiftClonableClient", dependencies: ["SwiftClonable"]),
    ]
)
