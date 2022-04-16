//
//  WebRepository.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

/// An ad-hoc network layer built on `URLSession` to perform an HTTP request.
public protocol WebRepository {
    /// A builder that constructs an HTTP request.
    var requestBuilder: URLRequestBuildable { get }
    
    /// A list of middlewares that will perform side effects whenever a request is sent or a response is received.
    var middlewares: [Middleware] { get }
    
    /// An object that coordinates a group of related, network data-transfer tasks.
    var session: URLSession { get }
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    ///   - resultQueue: A queue on which the promise is executed.
    ///   - decoder: An object decodes the data to result from JSON objects.
    ///   - resultType: The metatype instance of the result.
    ///   - promise: A promise to be fulfilled with a result represents either a success or a failure.
    /// - Returns: An URL session task that returns downloaded data directly to the app in memory.
    @discardableResult
    func call<T: Decodable>(
        to endpoint: Endpoint,
        resultQueue: DispatchQueue?,
        decoder: JSONDecoder,
        resultType: T.Type,
        promise: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask?
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    ///   - resultQueue: A queue on which the promise is executed. The default value is `nil`.
    ///   - promise: A promise to be fulfilled with a result represents either a success or a failure.
    /// - Returns: An URL session task that returns downloaded data directly to the app in memory.
    @discardableResult
    func call(
        to endpoint: Endpoint,
        resultQueue: DispatchQueue?,
        promise: @escaping (Result<Void, Error>) -> Void
    ) -> URLSessionDataTask?
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    ///   - decoder: An object decodes the data to result from JSON objects.
    ///   - resultType: The metatype instance of the result.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    func call<T: Decodable>(
        to endpoint: Endpoint,
        decoder: JSONDecoder,
        resultType: T.Type
    ) async throws -> T
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    func call(to endpoint: Endpoint) async throws
    
#if canImport(Combine)
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    ///   - decoder: An object decodes the data to result from JSON objects.
    ///   - resultType: The metatype instance of the result.
    /// - Returns: A publisher emits result of a request.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func call<T: Decodable>(
        to endpoint: Endpoint,
        decoder: JSONDecoder,
        resultType: T.Type
    ) -> AnyPublisher<T, Error>
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    /// - Returns: A publisher emits result of a request.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func call(to endpoint: Endpoint) -> AnyPublisher<Void, Error>
#endif
}

extension WebRepository {
    // MARK: Default Implementation
    
    /// Return a request to an endpoint that was cooked by a list of middlewares.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    ///   - middlewares: A list of middlewares that will perform side effects whenever a request is sent or a response is received.
    /// - Returns: A request that was cooked by a list of middlewares.
    private func makeRequest(endpoint: Endpoint, middlewares: [Middleware]) throws -> URLRequest {
        try middlewares.reduce(try requestBuilder.build(endpoint: endpoint)) { (partialResult: URLRequest, middleware: Middleware) in
            try middleware.prepare(request: partialResult)
        }
    }
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    ///   - promise: A promise to be fulfilled with a result represents either a success or a failure.
    /// - Returns: An URL session task that returns downloaded data directly to the app in memory.
    private func call(
        to endpoint: Endpoint,
        promise: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask? {
        do {
            let middlewares = middlewares
            let request = try makeRequest(endpoint: endpoint, middlewares: middlewares)
            let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                guard let response = response, let data = data else {
                    return promise(.failure(error ?? NetworkableError.empty))
                }
                let result = Result<Data, Error> {
                    try middlewares.forEach { try $0.didReceive(response: response, data: data) }
                    return data
                }
                promise(result)
            }
            middlewares.forEach { $0.willSend(request: request) }
            task.resume()
            return task
        } catch {
            promise(.failure(error))
            return nil
        }
    }
    
    @discardableResult
    public func call<T: Decodable>(
        to endpoint: Endpoint,
        resultQueue: DispatchQueue? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        resultType: T.Type = T.self,
        promise: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask? {
        call(to: endpoint) { (data: Result<Data, Error>) -> Void in
            let result = data.flatMap { (data: Data) in
                Result { try decoder.decode(resultType, from: data) }
            }
            guard let resultQueue = resultQueue else { return promise(result) }
            resultQueue.async { promise(result) }
        }
    }
    
    @discardableResult
    public func call(
        to endpoint: Endpoint,
        resultQueue: DispatchQueue? = nil,
        promise: @escaping (Result<Void, Error>) -> Void
    ) -> URLSessionDataTask? {
        call(to: endpoint) { (data: Result<Data, Error>) -> Void in
            let result = data.map { (_: Data) in () }
            guard let resultQueue = resultQueue else { return promise(result) }
            resultQueue.async { promise(result) }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension WebRepository {
    
    // MARK: Default Async Implementation
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    /// - Returns: The data returned by the server.
    private func call(to endpoint: Endpoint) async throws -> Data {
        let request = try makeRequest(endpoint: endpoint, middlewares: middlewares)
        middlewares.forEach { $0.willSend(request: request) }
        let (data, response) = try await session.data(for: request)
        try middlewares.forEach { try $0.didReceive(response: response, data: data) }
        return data
    }
    
    public func call<T: Decodable>(
        to endpoint: Endpoint,
        decoder: JSONDecoder = JSONDecoder(),
        resultType: T.Type = T.self
    ) async throws -> T {
        let data: Data = try await call(to: endpoint)
        let result = try decoder.decode(resultType, from: data)
        return result
    }
    
    public func call(to endpoint: Endpoint) async throws {
        let _: Data = try await call(to: endpoint)
    }
}

#if canImport(Combine)
@available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
extension WebRepository {
    // MARK: Default Publisher Implementation
    
    /// Call to a web resource specified by an endpoint.
    /// - Parameters:
    ///   - endpoint: An object abstracts a HTTP request.
    /// - Returns: A publisher emits result of a request.
    private func call(to endpoint: Endpoint) -> AnyPublisher<Data, Error> {
        do {
            let middlewares = middlewares
            let request = try makeRequest(endpoint: endpoint, middlewares: middlewares)
            return session
                .dataTaskPublisher(for: request)
                .handleEvents(receiveSubscription: { (_) in
                    middlewares.forEach { $0.willSend(request: request) }
                })
                .tryMap { (data: Data, response: URLResponse) -> Data in
                    try middlewares.forEach { try $0.didReceive(response: response, data: data) }
                    return data
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    public func call<T: Decodable>(
        to endpoint: Endpoint,
        decoder: JSONDecoder = JSONDecoder(),
        resultType: T.Type = T.self
    ) -> AnyPublisher<T, Error> {
        call(to: endpoint)
            .tryMap { (data: Data) -> T in
                try decoder.decode(resultType, from: data)
            }
            .eraseToAnyPublisher()
    }
    
    public func call(to endpoint: Endpoint) -> AnyPublisher<Void, Error> {
        call(to: endpoint)
            .map { (_: Data) in () }
            .eraseToAnyPublisher()
    }
}
#endif
