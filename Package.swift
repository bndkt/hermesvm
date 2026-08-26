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
            checksum: "428d4add7fad18970c5fe4f0f899a5d24753a61f6c5aa5ac9f4bef1545261e24"
        ),
        .target(
            name: "hermesvmHeaders",
            dependencies: ["hermesvm"],
            path: "Sources/hermesvmHeaders",
            publicHeadersPath: "include"
        ),
    ]
)
