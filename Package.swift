// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "hermesvm",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "hermesvm", targets: ["hermesvm", "_hermesvmStub"]),
    ],
    targets: [
        .binaryTarget(
            name: "hermesvm",
            url: "https://github.com/bndkt/hermesvm/releases/download/0.0.3/hermesvm.xcframework.zip",
            checksum: "188009dad6ee33aa0ff78c39b427bc684fe39aeb5b3d42c9e4bdadd78e8fbe1a"
        ),
        // Without at least one regular (non-binary) target, Xcode does not
        // embed a binary XCFramework. The stub is Swift so SwiftPM does not
        // require Sources/_hermesvmStub/include. The stub must not depend on
        // the binary and must not publish C++ headers.
        // See swift-package-manager#6069.
        .target(
            name: "_hermesvmStub",
            path: "Sources/_hermesvmStub"
        ),
    ]
)
