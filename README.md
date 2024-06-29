# RequestEasy

A Swift package to simplify HTTP GET requests with different types of responses.

## Installation

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/RequestPackage.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["RequestPackage"]),
]
