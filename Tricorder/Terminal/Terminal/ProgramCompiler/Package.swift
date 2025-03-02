// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProgramCompiler",
    products: [
        .library(
            name: "ProgramCompiler",
            targets: ["ProgramCompiler"]
		),
    ],
    targets: [
        .target(name: "ProgramCompiler"),
    ]
)
