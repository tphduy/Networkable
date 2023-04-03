//
//  NetworkableSession.swift
//  NetworkableTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

/// An ad-hoc network layer built on `URLSession` to perform an HTTP request.
public protocol NetworkableSession {
    // MARK: Promise
    
    /// Retrieves the contents that is specified by an HTTP request asynchronously.
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    ///   - resultQueue: A queue on which the promise will be fulfilled.
    ///   - decoder: An object decodes the data to result from JSON objects.
    ///   - promise: A promise to be fulfilled with a result represents either a success or a failure.
    /// - Returns: An URL session task that returns downloaded data directly to the app in memory.
    @discardableResult
    func dataTask<T>(
        for request: Request,
        resultQueue: DispatchQueue?,
        decoder: JSONDecoder,
        promise: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask? where T: Decodable
    
    /// Retrieves the contents that is specified by an HTTP request asynchronously.
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    ///   - resultQueue: A queue on which the promise will be fulfilled.
    ///   - promise: A promise to be fulfilled with a result represents either a success or a failure.
    /// - Returns: An URL session task that returns downloaded data directly to the app in memory.
    @discardableResult
    func dataTask(
        for request: Request,
        resultQueue: DispatchQueue?,
        promise: @escaping (Result<Void, Error>) -> Void
    ) -> URLSessionDataTask?
    
#if canImport(Combine)
    // MARK: Publiser
    
    /// Retrieves the contents that is specified by an HTTP request asynchronously.
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    ///   - resultQueue: A queue on which the promise will be fulfilled.
    ///   - decoder: An object decodes the data to result from JSON objects.
    /// - Returns: A publisher publishes decoded data when the task completes, or terminates if the task fails with an error.
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func dataTaskPublisher<T>(
        for request: Request,
        resultQueue: DispatchQueue?,
        decoder: JSONDecoder
    ) -> AnyPublisher<T, Error> where T: Decodable
    
    /// Retrieves the contents that is specified by an HTTP request asynchronously.
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    ///   - resultQueue: A queue on which the promise will be fulfilled.
    /// - Returns: A publisher publishes decoded data when the task completes, or terminates if the task fails with an error.
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func dataTaskPublisher(
        for request: Request,
        resultQueue: DispatchQueue?
    ) -> AnyPublisher<Void, Error>
#endif
    
    // MARK: Async
    
    /// Retrieves the contents that is specified by an HTTP request asynchronously.
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    ///   - decoder: An object decodes the data to result from JSON objects.
    /// - Returns: The decoded data.
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func data<T>(
        for request: Request,
        decoder: JSONDecoder
    ) async throws -> T where T: Decodable
    
    /// Retrieves the contents that is specified by an HTTP request asynchronously.
    /// - Parameters:
    ///   - request: A type that abstracts an HTTP request.
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func data(for request: Request) async throws
}
