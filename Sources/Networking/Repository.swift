//
//  Repository.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, *)
public protocol Repository {
    var requestFactory: URLRequestFactory { get }
    var middlewares: [Middleware] { get }
    var session: URLSession { get }
    var executionQueue: DispatchQueue { get }

    func call(to endpoint: Enpoint,
              acceptedInRange codes: HTTPCodes,
              resulttQueue: DispatchQueue) -> AnyPublisher<Data, Error>
}

@available(OSX 10.15, *)
extension Repository {
    private func prepare(request: URLRequest, middlewares: [Middleware]) throws -> URLRequest {
        var request = request
        for middleware in middlewares {
            request = try middleware.prepare(request: request)
        }
        return request
    }

    private func didReceive(response: URLResponse, middlewares: [Middleware]) throws {
        for middleware in middlewares {
            try middleware.didReceive(response: response)
        }
    }

    private func didReceive(data: Data, middlewares: [Middleware]) throws {
        for middleware in middlewares {
            try middleware.didReceive(data: data)
        }
    }

    private func task(request: URLRequest) -> AnyPublisher<Data, Error> {
        session
            .dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { (_) in
                for middleware in self.middlewares {
                    middleware.willSend(request: request)
                }
            })
            .subscribe(on: executionQueue)
            .tryMap { (data: Data, response: URLResponse) in
                try self.didReceive(response: response, middlewares: self.middlewares)
                try self.didReceive(data: data, middlewares: self.middlewares)
                return data
        }
        .eraseToAnyPublisher()
    }

    public func call(to endpoint: Enpoint,
                     acceptedInRange codes: HTTPCodes = .success,
                     resulttQueue: DispatchQueue = .main) -> AnyPublisher<Data, Error> {
        do {
            let request = try requestFactory.make(endpoint: endpoint)
            let preparedRequest = try prepare(request: request, middlewares: middlewares)
            let task = self.task(request: preparedRequest)
            return task
                .receive(on: resulttQueue)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    public func call<T: Decodable>(to endpoint: Enpoint,
                                   acceptedInRange codes: HTTPCodes = .success,
                                   resulttQueue: DispatchQueue = .main,
                                   decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        do {
            let request = try requestFactory.make(endpoint: endpoint)
            let preparedRequest = try prepare(request: request, middlewares: middlewares)
            let task = self.task(request: preparedRequest)
            return task
                .decode(type: T.self, decoder: decoder)
                .receive(on: resulttQueue)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

@available(OSX 10.15, *)
public struct DefaultRepository: Repository {
    public let requestFactory: URLRequestFactory
    public let middlewares: [Middleware]
    public let session: URLSession
    public let executionQueue: DispatchQueue

    public init(requestFactory: URLRequestFactory,
                middlewares: [Middleware] = [DefaultCodeValidationMiddleware(), DefaultLoggingMiddleware()],
                session: URLSession = .shared,
                executionQueue: DispatchQueue = DispatchQueue.global()) {
        self.requestFactory = requestFactory
        self.middlewares = middlewares
        self.session = session
        self.executionQueue = executionQueue
    }
}
#endif
