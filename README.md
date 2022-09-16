![Cover](Assets/Cover.png)

# Networkable

![Swift](https://github.com/duytph/Networkable/workflows/Swift/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/Networkable.svg?style=flat)](https://cocoapods.org/pods/Networkable)
[![License](https://img.shields.io/cocoapods/l/Networkable.svg?style=flat)](https://cocoapods.org/pods/Networkable)
[![Platform](https://img.shields.io/cocoapods/p/Networkable.svg?style=flat)](https://cocoapods.org/pods/Networkable)

## Overview

So the basic idea of **Networkable** is an ad-hoc network player built on top of `URLSession`. It should be simple enough that common things are easy but comprehensive enough that complicated things are also easy.

>**Why not Alamofire/Moya?**
>
> Compared to them, **Networkable** is a tiny handy library, aimed at the most basic things of a network layer that should behave, trigger a request then handle the response.
>If you are the type of developer who wants to manipulate everything under your scope, then an understandable package may be the thing you favor.

## Sample usage

```swift
/// An object provides methods for interacting with the crytocurrency market data in the remote database.
protocol RemoteCryptocurrencyMarketRepository {
    /// Get all available exchanges.
    /// - Parameter promise: A promise to be fulfilled with a result represents either a success or a failure. The success value is the cart data of a store.
    /// - Returns: A URL session task that returns downloaded data directly to the app in memory.
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask?
    
    /// Get all available exchanges.
    /// - Returns: An asynchronously-delivered list of exchanges.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func exchanges() async throws -> [Exchange]
    
    /// Get all available exchanges.
    /// - Returns: A publisher emits result of a request.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func exchanges() -> AnyPublisher<[Exchange], Error>
}

/// An object provides methods for interacting with the crytocurrency market data in the remote database.
struct DefaultRemoteCryptocurrencyMarketRepository: RemoteCryptocurrencyMarketRepository {
    // MARK: Dependencies
    
    /// An ad-hoc network layer built on URLSession to perform an HTTP request.
    let provider: WebRepository
    
    // MARK: Init
    
    /// Initiate an object provides methods for interacting with the crytocurrency market data in the remote database.
    /// - Parameter provider: An ad-hoc network layer built on URLSession to perform an HTTP request.
    init(provider: WebRepository = DefaultWebRepository(requestBuilder: URLRequestBuilder(baseURL: URL(string: "https://api.coincap.io")))) {
        self.provider = provider
    }
    
    // MARK: RemoteCryptocurrencyMarketRepository
    
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        provider.call(to: APIEndpoint.exchanges) { (result: Result<Datum<[Exchange]>, Error>) in
            promise(result.map({ $0.data }))
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func exchanges() async throws -> [Exchange] {
        try await provider
            .call(to: APIEndpoint.exchanges, resultType: Datum<[Exchange]>.self)
            .data
    }
    
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func exchanges() -> AnyPublisher<[Exchange], Error> {
        provider
            .call(to: APIEndpoint.exchanges, resultType: Datum<[Exchange]>.self)
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    // MARK: Subtypes - APIEndpoint
    
    /// An object abstracts an HTTP request.
    enum APIEndpoint: Endpoint {
        /// Get all available exchanges.
        case exchanges
        
        var headers: [String: String]? { nil }
        
        var url: String { "/v2/exchanges" }
        
        var method: Method { .get }
        
        func body() throws -> Data? { nil }
    }
}
```

## Sample project

```bash
cd NetworkableExample
pod install
open NetworkableExample.xcworkspace
```
 
 Wait for the Cocoapods to generate the workspace then you're good to go. 

`Networkable` use cases should be found in `UseCases` and `Repositories` directory.

## Features

1. Combine support
2. async/await support
2. Easy-peasy testing
3. Lets you define a clear usage of different endpoints with associated enum values
4. Middleware offers the capability of injecting logic
 - Authorize a request
 - Localize a request
 - Logging
 - Error handling
 - ...

## Requirements
- iOS 10.0+
- MacOS 10.12+
- tvOS 10.0+
- watchOS 3.0+
- Xcode 13.3.1+
- Swift 5.6+

## Installation

### Swift Package Manager

Embedded in a package

```swift
dependencies: [
 .package(url: "https://github.com/duytph/Networkable"),
]
```

Embedded in Xcode project

> 1. Open menu File > Swift Packages > Add Package Dependency...
> 2. Enter https://github.com/duytph/Networkable

### Cocoapods

```ruby
pod 'Networkable'
```

### Carthage

Not implemented

## Author

duytph, tphduy@gmail.com

## License

Networkable is available under the MIT license. See the LICENSE file for more info.

