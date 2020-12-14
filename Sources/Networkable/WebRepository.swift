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

/// An Ad-hoc network layer built on `URLSession` to query web resources.
public protocol WebRepository {
    
    /// An object to construct request
    var requestFactory: URLRequestFactory { get }
    
    /// Middlewares perform side effects whenever a request is sent or a response is received.
    var middlewares: [Middleware] { get }
    
    /// An object that coordinates a group of related, network data-transfer tasks.
    var session: URLSession { get }
    
    #if canImport(Combine)
    /// Call to a web resource specified by an endpoint
    /// - Parameters:
    ///   - endpoint: An object re-presents a HTTP request.
    ///   - executionQueue: A queue on which a request is proccessed.
    ///   - resultQueue: A queue on which a response is proccessed.
    ///   - decoder: An object decodes the data to result from JSON objects.
    /// - Returns: A publisher emits result of a request.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func call<T: Decodable>(
        to endpoint: Endpoint,
        executionQueue: DispatchQueue,
        resultQueue: DispatchQueue,
        decoder: JSONDecoder) -> AnyPublisher<T, Error>
    #endif
    
    /// Call to a web resource specified by an endpoint
    /// - Parameters:
    ///   - endpoint: An object re-presents a HTTP request.
    ///   - resultQueue: A queue on which a response is proccessed.
    ///   - decoder: An object decodes the data to result from JSON objects.
    ///   - promise: The code to be executed once the request has finished.
    /// - Returns: A URL session task that returns downloaded data directly to the app in memory.
    func call<T: Decodable>(
        to endpoint: Endpoint,
        resultQueue: DispatchQueue,
        decoder: JSONDecoder,
        promise: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask?
}

extension WebRepository {
    
    func makeRequest(
        endpoint: Endpoint,
        middlewares: [Middleware]) throws -> URLRequest {
        var request = try requestFactory.make(endpoint: endpoint)
        for middleware in middlewares {
            request = try middleware.prepare(request: request)
        }
        return request
    }
    
    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public func call<T: Decodable>(
        to endpoint: Endpoint,
        executionQueue: DispatchQueue = .global(),
        resultQueue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        do {
            let middlewares = self.middlewares
            let request = try makeRequest(
                endpoint: endpoint,
                middlewares: middlewares)
            
            return session
                .dataTaskPublisher(for: request)
                .subscribe(on: executionQueue)
                .receive(on: resultQueue)
                .handleEvents(receiveSubscription: { (_) in
                    middlewares.forEach { $0.willSend(request: request) }
                })
                .tryMap { (data: Data, response: URLResponse) in
                    try middlewares.forEach { try $0.didReceive(response: response, data: data) }
                    guard !data.isEmpty else { throw NetworkableError.empty }
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    #endif
    
    @discardableResult
    public func call<T: Decodable>(
        to endpoint: Endpoint,
        resultQueue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        promise: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask? {
        let completion = { (result: Result<T, Error>) in
            resultQueue.async { promise(result) }
        }
        
        do {
            let middlewares = self.middlewares
            let request = try makeRequest(
                endpoint: endpoint,
                middlewares: middlewares)
            let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    return completion(.failure(error))
                }
                
                guard
                    let response = response,
                    let data = data,
                    !data.isEmpty
                else {
                    return completion(.failure(NetworkableError.empty))
                }
                
                let result = Result<T, Error> {
                    try middlewares.forEach { try $0.didReceive(response: response, data: data) }
                    let result = try decoder.decode(T.self, from: data)
                    return result
                }
                completion(result)
            }
            middlewares.forEach { $0.willSend(request: request) }
            task.resume()
            return task
        } catch {
            completion(.failure(error))
            return nil
        }
    }
}

public struct DefaultWebRepository: WebRepository {
    
    static let shared = DefaultWebRepository()
    
    // MARK: - Dependencies
    
    public var requestFactory: URLRequestFactory
    public var middlewares: [Middleware]
    public var session: URLSession
    
    // MARK: - Init
    
    public init(
        requestFactory: URLRequestFactory = DefaultURLRequestFactory(),
        middlewares: [Middleware] = [LoggingMiddleware()],
        session: URLSession = .shared) {
        self.requestFactory = requestFactory
        self.middlewares = middlewares
        self.session = session
    }
}
