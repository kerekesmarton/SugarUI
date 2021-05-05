// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SugarUI",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SugarUI",
            targets: ["SugarUI"]),
    ],
    dependencies: [
//        .package(path: "../Sugar"),
        .package(url: "https://github.com/kerekesmarton/Sugar.git", Package.Dependency.Requirement.branch("master")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.10.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
        .package(url: "https://github.com/hubrioAU/SFSymbols.git", from: "0.9.5"),
        .package(url: "https://github.com/fermoya/SwiftUIPager.git", from: "2.1.0")        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SugarUI",
            dependencies: [
                "Sugar",
                "SDWebImageSwiftUI",
                "SFSymbols",
                "SwiftUIPager"
            ]),
        .testTarget(
            name: "SugarUITests",
            dependencies: ["SugarUI"]),
    ]
)
