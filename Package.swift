// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Tracer",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "Tracer", targets: ["Tracer"]),
        .library(name: "TracerUI", targets: ["TracerUI"]),
    ],
    dependencies: [],
    targets: [
        // Product Targets
        .target(
            name: "Tracer",
            dependencies: []
        ),
        .target(
            name: "TracerUI",
            dependencies: [
                .target(name: "Tracer"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        // Test Targets
        .testTarget(
            name: "TracerTests",
            dependencies: [
                .target(name: "Tracer"),
            ]
        ),
    ]
)
