// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "simrun",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .executable(name: "simrun", targets: ["simrun"]),
    .library(
      name: "SimrunCore",
      type: .static,
      targets: ["simrun"]
    ),
    ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/ShellOut", from: "1.2.1"),
    .package(url: "https://github.com/kylef/Commander", from: "0.6.1"),
//    .package(url: "https://github.com/saoudrizwan/Disk", from: "0.2.4"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "simrun",
      dependencies: [
        "SimrunCore",
        "Commander",
        ]
    ),
    .target(
      name: "SimrunCore",
      dependencies: [
        "ShellOut",
      ]
    ),
    .testTarget(
      name: "simrunTests",
      dependencies: ["simrun"]
    ),
    ]
)
