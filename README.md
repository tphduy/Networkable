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
/// An object provides methods for interacting with the crytocurrency market data in the remote database.
protocol RemoteCryptocurrencyMarketRepository {
    /// Get all available exchanges.
    /// - Parameter promise: A promise to be fulfilled with a result represents either a success or a failure.
    /// - Returns: A URL session task that returns downloaded data directly to the app in memory.
    @discardableResult
    func exchangesTask(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask?
    
    /// Get all available exchanges.
    /// - Returns: A publisher emits a list of exchanges
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchangesPublisher() -> AnyPublisher<[Exchange], Error>
    
    /// Get all available exchanges.
    /// - Returns: An asynchronously-delivered list of exchanges.
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchanges() async throws -> [Exchange]
}

/// An object provides methods for interacting with the crytocurrency market data in the remote database.
final class DefaultRemoteCryptocurrencyMarketRepository: RemoteCryptocurrencyMarketRepository {
    // MARK: Dependencies
    
    /// An ad-hoc network layer that is built on `URLSession` to perform an HTTP request.
    let session: NetworkableSession
    
    // MARK: Init
    
    /// Initiate an object provides methods for interacting with the crytocurrency market data in the remote database.
    /// - Parameter session: An ad-hoc network layer that is built on `URLSession` to perform an HTTP request.
    init(session: NetworkableSession = NetworkSession.coincap) {
        self.session = session
    }
    
    // MARK: RemoteCryptocurrencyMarketRepository
    
    @discardableResult
    func exchangesTask(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        session.dataTask(
            for: API.exchanges,
            resultQueue: nil,
            decoder: JSONDecoder()
        ) { (result: Result<Datum<[Exchange]>, Error>) in
            let exchanges = result.map { $0.data }
            promise(exchanges)
        }
    }
    
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchangesPublisher() -> AnyPublisher<[Exchange], Error> {
        session
            .dataTaskPublisher(
                for: API.exchanges,
                resultQueue: nil,
                decoder: JSONDecoder())
            .map(\Datum<[Exchange]>.data)
            .eraseToAnyPublisher()
    }
    
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchanges() async throws -> [Exchange] {
        let datum = try await session.data(for: API.exchanges, decoder: JSONDecoder()) as Datum<[Exchange]>
        return datum.data
    }
    
    // MARK: Subtypes - API
    
    /// An object abstracts an HTTP request.
    private enum API: Request {
        /// Get all available exchanges.
        case exchanges
        
        // MARK: Request
        
        var headers: [String: String]? { nil }
        
        var url: String { "/v2/exchanges" }
        
        var method: Networkable.Method { .get }
        
        func body() throws -> Data? { nil }
    }
}

```

## Sample project

```bash
cd NetworkableExample
pod install
open NetworkableExample.xcworkspace/
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
