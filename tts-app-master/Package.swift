// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CommunicationAssistant",
    platforms: [
        .iOS(.v17),
        .macOS(.v14) // Add macOS support for local testing
    ],
    products: [
        .library(
            name: "CommunicationAssistant",
            targets: ["CommunicationAssistant"]),
    ],
    targets: [
        .target(
            name: "CommunicationAssistant",
            path: "CommunicationAssistant",
            exclude: ["App/CommunicationAssistantApp.swift", "Resources"] // Exclude App entry point
        ),
        .testTarget(
            name: "CommunicationAssistantTests",
            dependencies: ["CommunicationAssistant"],
            path: "CommunicationAssistantTests"
        ),
    ]
)