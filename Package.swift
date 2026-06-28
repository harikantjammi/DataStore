// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let approachableConcurrencySettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "DataStore",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataStore",
            targets: ["DataStore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/appwrite/sdk-for-apple", .upToNextMinor(from: "17.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataStore",
            dependencies: [.product(name: "Appwrite", package: "sdk-for-apple")],
            swiftSettings: approachableConcurrencySettings),
        .testTarget(
            name: "DataStoreTests",
            dependencies: ["DataStore"],
            swiftSettings: approachableConcurrencySettings
        ),
    ]
)
