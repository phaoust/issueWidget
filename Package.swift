// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IssueWidget",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "issueWidget",
            targets: ["CLI"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CLI",
            dependencies: ["Shared"],
            path: "IssueWidget/CLI"
        ),
        .target(
            name: "Shared",
            path: "IssueWidget/Shared"
        )
    ]
)
