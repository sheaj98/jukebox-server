// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "jukebox-vapor",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.1"),
        .package(url: "https://github.com/iamjono/SwiftRandom.git", from: "1.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor.git", from: "1.1.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.6.1")
        
    ],
    targets: [
    .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "SwiftRandom","SwiftyBeaverVapor","SwiftyBeaver"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

