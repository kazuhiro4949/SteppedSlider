// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SteppedSlider",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "SteppedSlider", targets: ["SteppedSlider"])
    ],
    targets: [
        .target(name: "SteppedSlider", path: "SteppedSlider")
    ]
)
