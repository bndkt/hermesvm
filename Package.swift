// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "hermesvm",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "hermesvm", targets: ["hermesvm", "hermesvmHeaders"]),
    ],
    targets: [
        .binaryTarget(
            name: "hermesvm",
            url: "https://github.com/bndkt/hermesvm/releases/download/0.0.1/hermesvm.xcframework.zip",
            checksum: "cfbe7987de678e5d3cc7b0c0d85c370692048091d773d67ff63d5cb679cc795a"
        ),
        .target(
            name: "hermesvmHeaders",
            dependencies: ["hermesvm"],
            path: "Sources/hermesvmHeaders",
            publicHeadersPath: "include"
        ),
    ]
)
