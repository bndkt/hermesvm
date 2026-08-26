# hermesvm

This repository is a Swift Package. The package name is `hermesvm`.

The package ships `hermesvm.xcframework`. That file is the Hermes runtime for iOS. The generated Xcode project of an ursprung app adds `https://github.com/bndkt/hermesvm`.

Version `0.0.3` ships Hermes iOS build `260318099.0.1`. A GitHub Release on that tag holds `hermesvm.xcframework.zip` and a matching macOS `hermesc`. Compiler and VM match. The XCFramework carries Hermes and JSI headers. The library product includes a Swift stub so Xcode can embed the binary. The stub is Swift so SwiftPM does not look for `Sources/_hermesvmStub/include`.

`Package.swift` sits at the repository root. It declares a binary target for `hermesvm.xcframework`.

CI reads `pin.env`. CI fetches that Hermes iOS build. CI writes the zip, the checksum, `Package.swift`, and a Git tag. CI does not use npm. CI does not use CocoaPods `hermes-engine`.

Hermes is MIT. Copyright Meta Platforms, Inc. and affiliates. The package sources are MIT. Copyright Benedikt Müller.
