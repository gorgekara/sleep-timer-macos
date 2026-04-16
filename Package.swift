// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SleepTimerApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SleepTimerApp",
            targets: ["SleepTimerApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SleepTimerApp",
            path: "Sources"
        )
    ]
)
