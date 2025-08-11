// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BudgetCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "BudgetCore", targets: ["BudgetCore"])
    ],
    targets: [
        .target(
            name: "BudgetCore",
            path: "Sources/BudgetCore"
        ),
        .testTarget(
            name: "BudgetCoreTests",
            dependencies: ["BudgetCore"],
            path: "Tests/BudgetCoreTests"
        )
    ]
)