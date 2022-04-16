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
                "SwiftRTOW.swift",
                "ButtonStyle.swift",
                "Fsm.swift",
                "Finder.swift",
                "Paddle.swift",
                "Exception.swift",
                "Responsive.swift",
                "Extension.swift",
                "Stack.swift",
                "CpuRTOW/Rtow.swift",
                "CpuRTOW/Thing.swift",
                "CpuRTOW/Sphere.swift",
                "CpuRTOW/Things.swift",
                "CpuRTOW/Optics.swift",
                "CpuRTOW/Camera.swift",
                "CpuRTOW/Ray.swift",
                "CpuRTOW/V.swift",
                "CpuRTOW/Util.swift",
                "CpuRTOW/Ch8.swift",
                "CpuRTOW/Ch10.swift",
                "CpuRTOW/Ch13.swift"],
            swiftSettings: [
                // .define("RECURSIVE"), // default ITERATIVE
                // .define("SINGLETASK"), // default CONCURRENT
                ]),
    ]
)
