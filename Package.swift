import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "http://github.com/Balancingrock/SwifterJSON", "0.9.14"),
        .Package(url: "http://github.com/Balancingrock/SwifterSockets", "0.9.12")
    ]
)
