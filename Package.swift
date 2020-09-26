// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DataField",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [.library(name: "DataField", targets: ["DataField"])],
    targets: [.target(name: "DataField", dependencies: [])]
)
