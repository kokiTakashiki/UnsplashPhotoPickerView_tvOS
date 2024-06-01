// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnsplashPhotoPickerView_tvOS",
    platforms: [
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UnsplashPhotoPickerView_tvOS",
            targets: ["UnsplashPhotoPickerView_tvOS"]),
    ],
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(url: "https://github.com/kokiTakashiki/unsplash-photopicker-ios.git", branch: "develop")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UnsplashPhotoPickerView_tvOS",
            dependencies: [
                .product(name: "UnsplashPhotoPicker", package: "unsplash-photopicker-ios"),
                .product(name: "UnsplashPhotoPickerUI_tvOS", package: "unsplash-photopicker-ios")
            ]
        ),
        .testTarget(
            name: "UnsplashPhotoPickerView_tvOSTests",
            dependencies: ["UnsplashPhotoPickerView_tvOS"]),
    ]
)
