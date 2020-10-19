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
protocol MovieRepository {
    
    func movie(id: Int, promise: @escaping (Result<Movie, Error>) -> Void)
    func movie(id: Int) -> AnyPublisher<Movie, Error>
}

struct DefaultMovieRepository: MovieRepository, Repository {
    
    var requestFactory: URLRequestFactory = DefaultURLRequestFactory(baseURL: "https://api.themoviedb.org/3")
    var middlewares: [Middleware] = [DefaultLoggingMiddleware()]
    var session: URLSession = .shared
    
    func movie(id: Int, promise: @escaping (Result<Movie, Error>) -> Void) {
        let endpoint = APIEndpoint.movie(id: id)
        call(to: endpoint, promise: promise)
    }
    
    func movie(id: Int) -> AnyPublisher<Movie, Error> {
        let endpoint = APIEndpoint.movie(id: id)
        return call(to: endpoint)
    }
}

extension DefaultMovieRepository {
    
    enum APIEndpoint: Networking.Endpoint {
        
        case movie(id: Int)
        
        var path: String {
            switch self {
            case let .movie(id): return "/movie/\(id)"
            }
        }
        
        var method: Networking.Method {
            switch self {
            case .movie: return .get
            }
        }
        
        func body() throws -> Data? {
            switch self {
            case .movie: return nil
            }
        }
    }
}
```

## Sample project

I have provided a sample projects in https://github.com/duytph/Moviable. To use it download the repo, wait for Xcode resolve dependency and you're good to go. 

`Networiking` use cases should be found in `Repositories` directory.

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