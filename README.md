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
>Comparing to them, **Networkable** is a tiny handy library, aimed at the most basic things of a network layer should behave, trigger a request then handle the response.
>If you are the type of developer who wants to manipulate everything under your scope, then an understandable package maybe the thing you favor.

## Sample usage

```swift
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
        struct Datum: Codable { let data: [Exchange] }
        return provider.call(to: APIEndpoint.exchanges) { (result: Result<Datum, Error>) in
            promise(result.map({ $0.data }))
        }
    }
    
#if canImport(Combine)
    func exchanges() -> AnyPublisher<[Exchange], Error> {
        struct Datum: Codable { let data: [Exchange] }
        return provider
            .call(to: APIEndpoint.exchanges, resultType: Datum.self)
            .map(\.data)
            .eraseToAnyPublisher()
    }
#endif
    
    // MARK: Subtypes - APIEndpoint
    
    /// An object abstracts a HTTP request.
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

1. Combine Support
2. Easy-peasy testing
3. Lets you define a clear usage of different endpoints with associated enum values
4. Middleware offers the capability of injecting logic
    - Authenticate request
    - Localize request
    - Logging
    - Error handling
    - ...

## Requirements
- iOS 10+
- MacOS 10.12+
- tvOS 10.0+
- watchOS 3.0+
- Xcode 12+
- Swift 5.3+

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
