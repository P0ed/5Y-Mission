// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProgramCompiler",
	platforms: [
		.iOS(.v17),
		.macOS(.v14),
		.watchOS(.v10),
		.tvOS(.v17)
	],
    products: [
        .library(
            name: "ProgramCompiler",
            targets: ["ProgramCompiler", "Machine"]
		),
    ],
    targets: [
		.target(name: "ProgramCompiler", dependencies: ["Machine"]),
		.target(name: "Machine"),
		.testTarget(name: "CompilerTests", dependencies: ["ProgramCompiler", "Machine"])
    ]
)
