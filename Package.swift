// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CalendarAgent",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Calendar Agent", targets: ["CalendarAgent"])
    ],
    targets: [
        .executableTarget(
            name: "CalendarAgent",
            dependencies: [],
            path: "Sources"
        )
    ]
)
