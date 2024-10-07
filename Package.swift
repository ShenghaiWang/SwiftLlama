// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftLlama",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11),
        .tvOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "SwiftLlama", targets: ["SwiftLlama"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ggerganov/llama.cpp.git", branch: "master")
    ],
    targets: [
        .target(name: "SwiftLlama", 
                dependencies: [
                    .product(name: "llama", package: "llama.cpp")
                ]),
        .testTarget(name: "SwiftLlamaTests", dependencies: ["SwiftLlama"]),
    ]
)
