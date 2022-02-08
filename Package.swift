// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRTOW",
    platforms: [
        .iOS(.v15),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SwiftRTOW",
            dependencies: [],
            sources: [
                "RtowView.swift",
                "UIImage.swift",
                "Fsm.swift",
                "Rtow.swift",
                "Thing.swift",
                "Sphere.swift",
                "Things.swift",
                "Optics.swift",
                "Camera.swift",
                "Ray.swift",
                "V.swift",
                "Ch8.swift",
                "Ch10.swift",
                "Ch13.swift"],
            swiftSettings: [
                // .define("RECURSIVE"), // default ITERATIVE
                // .define("SINGLETASK"), // default CONCURRENT
                ]),
    ]
)
