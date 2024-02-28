# DrawingView
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) ![SwiftPM: compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-red)

DrawingView is an iOS UI component that parses SVG images, recognizes each path and determines the degree of consistency with the path drawn by the user.

## Features
Two types of input data are required:
1. Vector image data divided into each pass to express the image.
2. Vector data that can find the consistency with the user's drawing value.

It is not possible to read general SVG files; only files with one stroke per stroke are possible.
The SVG files used in the sample app was created using Boxy SVG Editor. (https://boxy-svg.com/app)

When the user draws a stroke, the data is compared for agreement.
If the match is above a certain percentage, the stroke is marked as drawn.

## Dependencies
- [Pocket SVG](https://github.com/pocketsvg/PocketSVG)

## Installation
### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/debugholic/drawingview.git", from: "1.0.0")
]
```

In Xcode 11+, add pacakge directly as a dependency to your project with
`File` > `Swift Packages` > `Add Package Dependency...`. Provide the git URL when prompted: `https://github.com/debugholic/drawingview.git`.

