// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WodTimer",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "WodTimerShared",
            dependencies: [],
            path: "WodTimerShared"
        ),
        .testTarget(
            name: "WodTimerTests",
            dependencies: ["WodTimerShared"],
            path: "WodTimerTests"
        )
    ]
)
