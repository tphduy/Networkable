//
//  NetworkSession.swift
//  
//
//  Created by Duy Tran on 15/04/2022.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

/// An ad-hoc network layer that is built on URLSession to perform an HTTP request.
public final class NetworkSession: NetworkableSession {
    // MARK: Dependencies
    
    /// A type can build an URL load request that is independent of protocol or URL scheme.
    let requestBuilder: URLRequestBuildable
    
    /// A list of middlewares that will perform side effects whenever a request is sent or a response is received.
    let middlewares: [Middleware]
    
    /// An object that coordinates a group of related, network data-transfer tasks.
    let session: URLSession
    
    // MARK: Init
    
    /// Initiates an ad-hoc network layer that is built on URLSession to perform an HTTP request.
    /// - Parameters:
    ///   - requestBuilder: A type can build an URL load request that is independent of protocol or URL scheme.
    ///   - middlewares: A list of middlewares that will perform side effects whenever a request is sent or a response is received.
    ///   - session: An object that coordinates a group of related, network data-transfer tasks.
    public init(
        requestBuilder: URLRequestBuildable = URLRequestBuilder(),
        middlewares: [Middleware] = [],
        session: URLSession = .shared
    ) {
        self.requestBuilder = requestBuilder
        self.middlewares = middlewares
        self.session = session
    }
    
    //  MARK: Utilities
    
    /// Makes an URL load request that is independent of protocol or URL scheme from a model.
    ///
    /// It will invoke the middlewares to perform side effects leading the final result.
    ///
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    ///   - middlewares: A list of middlewares that will perform side effects whenever a request is sent or a response is received.
    /// - Returns: An URL load request that is independent of protocol or URL scheme.
    private func makeRequest(
        of request: Request,
        middlewares: [Middleware]
    ) throws -> URLRequest {
        let seed = try requestBuilder.build(request: request)
        let result = try middlewares.reduce(seed) { (partialResult: URLRequest, middleware: Middleware) in
            try middleware.prepare(request: partialResult)
        }
        return result
    }
    
    // MARK: NetworkableSession
    
    private func dataTask(
        for request: Request,
        promise: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask? {
        do {
            // Makes an URL load request.
            let request = try makeRequest(of: request, middlewares: middlewares)
            // Makes a data task.
            let result = session.dataTask(with: request) { [middlewares] (data: Data?, response: URLResponse?, error: Error?) in
                // Verifies whether an error occurred.
                if let error {
                    // Notifies the middlewares.
                    middlewares.forEach { (middleware: Middleware) in
                        middleware.didReceive(error: error, of: request)
                    }
                    // Fulfills the promise and returns.
                    return promise(.failure(error))
                }
                // Make the result of request loading.
                let result = Result<Data, Error> {
                    // Makes sure the data is some or empty instead of none.
                    let data = data ?? Data()
                    // Verifies the response is some.
                    guard let response else { return data }
                    // Notifies the middlewares.
                    try middlewares.forEach { (middleware: Middleware) in
                        try middleware.didReceive(response: response, data: data)
                    }
                    // Return the data.
                    return data
                }
                // Fulfills the promise.
                promise(result)
            }
            // Notifies the middlewares.
            middlewares.forEach { (middleware: Middleware) in
                middleware.willSend(request: request)
            }
            // Starts to load the request.
            result.resume()
            // Returns the result.
            return result
        } catch {
            // Fulfills the promise.
            promise(.failure(error))
            // Returns the result.
            return nil
        }
    }
    
    @discardableResult
    public func dataTask<T>(
        for request: Request,
        resultQueue: DispatchQueue? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        promise: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask? where T: Decodable {
        // Makes a data task.
        dataTask(for: request) { (data: Result<Data, Error>) in
            // Makes a result of data decoding.
            let result = data.flatMap { (data: Data) -> Result<T, Error> in
                Result {
                    try decoder.decode(T.self, from: data)
                }
            }
            // Verifies the result queue is some.
            guard let resultQueue else {
                // Dispatchs the result on the current queue.
                return promise(result)
            }
            // Dispatchs the result on the result queue.
            resultQueue.async {
                promise(result)
            }
        }
    }
    
    @discardableResult
    public func dataTask(
        for request: Request,
        resultQueue: DispatchQueue? = nil,
        promise: @escaping (Result<Void, Error>) -> Void
    ) -> URLSessionDataTask? {
        // Makes a data task.
        dataTask(for: request) { (data: Result<Data, Error>) in
            // Ignores the data.
            let result = data.map { _ in () }
            // Verifies the result queue is some.
            guard let resultQueue else {
                // Dispatchs the result on the current queue.
                return promise(result)
            }
            // Dispatchs the result on the result queue.
            resultQueue.async {
                promise(result)
            }
        }
    }
    
#if canImport(Combine)
    // MARK: NetworkableSession - Publiser
    
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private func dataTaskPublisher(
        for request: Request,
        resultQueue: DispatchQueue?
    ) -> AnyPublisher<Data, Error> {
        do {
            // Makes an URL load request.
            let request = try makeRequest(of: request, middlewares: middlewares)
            // Make the data task publisher.
            let result = session
                .dataTaskPublisher(for: request)
                .handleEvents(
                    receiveSubscription: { [middlewares] (_) in
                        // Notifies the middlewares.
                        middlewares.forEach { (middleware: Middleware) in
                            middleware.willSend(request: request)
                        }
                    },
                    receiveCompletion: { [middlewares] (completion) in
                        guard case let .failure(error) = completion else { return }
                        // Notifies the middlewares.
                        middlewares.forEach { (middleware: Middleware) in
                            middleware.didReceive(error: error, of: request)
                        }
                    })
                .tryMap { [middlewares] (data: Data, response: URLResponse) -> Data in
                    // Notifies the middlewares.
                    try middlewares.forEach { (middleware: Middleware) in
                        try middleware.didReceive(response: response, data: data)
                    }
                    // Return the data.
                    return data
                }
            // Verifies the result queue is some.
            guard let resultQueue else {
                // Returns the result.
                return result.eraseToAnyPublisher()
            }
            // Return the result whose downstream messages will be dispatched on the result queue.
            return result
                .receive(on: resultQueue)
                .eraseToAnyPublisher()
        } catch {
            // Returns the result.
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func dataTaskPublisher<T>(
        for request: Request,
        resultQueue: DispatchQueue? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, Error> where T: Decodable {
        // Makes a data task publisher.
        dataTaskPublisher(for: request, resultQueue: resultQueue)
            .decode(type: T.self, decoder: decoder) // Decodes data.
            .eraseToAnyPublisher()
    }
    
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func dataTaskPublisher(
        for request: Request,
        resultQueue: DispatchQueue?
    ) -> AnyPublisher<Void, Error> {
        // Makes a data task publisher.
        dataTaskPublisher(for: request, resultQueue: resultQueue)
            .map { (_: Data) in () } // Ignores the data.
            .eraseToAnyPublisher()
    }
#endif
    
    // MARK: NetworkableSession - Async
    
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private func data(for request: Request) async throws -> Data {
        // Makes an URL load request.
        let request = try makeRequest(of: request, middlewares: middlewares)
        // Make a flag to indicate whether it should notify the middlewares about some errors.
        var shouldForwardError = true
        do {
            // Notifies the middlewares.
            middlewares.forEach { (middleware: Middleware) in
                middleware.willSend(request: request)
            }
            // Loads the request.
            let (data, response) = try await session.data(for: request)
            // Avoids notifying the middlewares about any possible errors below
            shouldForwardError = false
            // Notifies the middlewares.
            try middlewares.forEach { (middleware: Middleware) in
                try middleware.didReceive(response: response, data: data)
            }
            // Returns the result.
            return data
        } catch {
            // Verifies whether it should notifies the middlewares about an error.
            guard shouldForwardError else { throw error }
            // Notifies the middlewares.
            middlewares.forEach { (middleware: Middleware) in
                middleware.didReceive(error: error, of: request)
            }
            // Returns the result.
            throw error
        }
    }
    
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func data<T>(
        for request: Request,
        decoder: JSONDecoder
    ) async throws -> T where T: Decodable {
        // Makes an URL load request.
        let data = try await data(for: request) as Data
        // Decodes the data to result type.
        let result = try decoder.decode(T.self, from: data)
        // Returns the result.
        return result
    }
    
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func data(for request: Request) async throws {
        // Makes an URL load request.
        let _ = try await data(for: request) as Data
    }
}
