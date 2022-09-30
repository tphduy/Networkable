![Cover](Assets/Cover.png)

# Networkable

![Swift](https://github.com/duytph/Networkable/workflows/Swift/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/Networkable.svg?style=flat)](https://cocoapods.org/pods/Networkable)
[![License](https://img.shields.io/cocoapods/l/Networkable.svg?style=flat)](https://cocoapods.org/pods/Networkable)
[![Platform](https://img.shields.io/cocoapods/p/Networkable.svg?style=flat)](https://cocoapods.org/pods/Networkable)

## Overview

So the basic idea of **Networkable** is an ad-hoc network player built on top of `URLSession`. It should be simple enough that common things are easy but comprehensive enough that complicated things are also easy.

> **Why not Alamofire/Moya?**
>
> Compared to them, **Networkable** is a tiny handy library, aimed at the most basic things of a network layer that should behave, triggers a request then handles the response.
> If you are the type of developer who wants to manipulate everything under your scope, then an understandable package may be the thing you favor.

## Sample usage

```swift

```

## Sample project

```bash

```

Waits for the Cocoapods to generate the workspace then you're good to go.

`Networkable` use cases should be found in `UseCases` and `Repositories` directory.

## Features

1. Combine support
2. async/await support
3. Easy-peasy testing
4. Lets you define a clear usage of different endpoints with associated enum values
5. The middleware offers the capability of injecting logic:
   - Authorization
   - Localization
   - Logging
   - Error handling
   - ...

## Requirements

- macOS 10.12+
- iOS 8.0+
- tvOS 10.0+
- watchOS 3.0+

## Installation

### Swift Package Manager

Embedded in a package

```swift
dependencies: [
    .package(url: "https://github.com/duytph/Networkable"),
]
```

Embedded in Xcode project

1. Open menu File > Swift Packages > Add Package Dependency...
2. Enter https://github.com/duytph/Networkable

### Cocoapods

```ruby
pod 'Networkable'
```

### Carthage

Not implemented

## Author

Duy Tran (tphduy@gmail.com)

## License

Networkable is available under the MIT license. See the LICENSE file for more info.
