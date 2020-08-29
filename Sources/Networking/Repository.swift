//
//  Repository.swift
//  NetworkingTests
//
//  Created by Duy Tran on 7/13/20.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

public protocol Repository {
    var requestFactory: URLRequestFactory { get }
    var middlewares: [Middleware] { get }
    var session: URLSession { get }

    #if canImport(Combine)
    @available(iOS 13.0, OSX 10.15, *)
    func call<T: Decodable>(
        to endpoint: Endpoint,
        executionQueue: DispatchQueue,
        resulttQueue: DispatchQueue,
        decoder: JSONDecoder) -> AnyPublisher<T, Error>
    #endif

    func call<T: Decodable>(
        to endpoint: Endpoint,
        resulttQueue: DispatchQueue,
        decoder: JSONDecoder,
        promise: @escaping (Result<T, Error>) -> Void)
}

extension Repository {
    private func prepare(request: URLRequest, middlewares: [Middleware]) throws -> URLRequest {
        var request = request
        for middleware in middlewares {
            request = try middleware.prepare(request: request)
        }
        return request
    }

    #if canImport(Combine)
    @available(iOS 13.0, OSX 10.15, *)
    public func call<T: Decodable>(
        to endpoint: Endpoint,
        executionQueue: DispatchQueue = .global(),
        resulttQueue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        do {
            let middlewares = self.middlewares
            let request = try requestFactory.make(endpoint: endpoint)
            let preparedRequest = try prepare(request: request, middlewares: middlewares)

            return session
                .dataTaskPublisher(for: preparedRequest)
                .handleEvents(receiveSubscription: { (_) in
                    for middleware in middlewares {
                        middleware.willSend(request: request)
                    }
                })
                .subscribe(on: executionQueue)
                .tryMap { (data: Data, response: URLResponse) in
                    for middleware in middlewares {
                        try middleware.didReceive(response: response, data: data)
                    }
                    return data
            }
            .decode(type: T.self, decoder: decoder)
            .receive(on: resulttQueue)
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    #endif

    public func call<T: Decodable>(
        to endpoint: Endpoint,
        resulttQueue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        promise: @escaping (Result<T, Error>) -> Void) {
        let completion = { (result: Result<T, Error>) in
            resulttQueue.async {
                promise(result)
            }
        }

        do {
            let middlewares = self.middlewares
            let request = try requestFactory.make(endpoint: endpoint)
            let preparedRequest = try prepare(request: request, middlewares: middlewares)

            let task = session.dataTask(with: preparedRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    return completion(.failure(error))
                }

                guard let response = response, let data = data else {
                    return completion(.failure(NetworkingError.empty))
                }

                do {
                    for middleware in middlewares {
                        try middleware.didReceive(response: response, data: data)
                    }

                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }

            for middleware in middlewares {
                middleware.willSend(request: preparedRequest)
            }

            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}

@available(OSX 10.15, *)
public struct DefaultRepository: Repository {
    public let requestFactory: URLRequestFactory
    public let middlewares: [Middleware]
    public let session: URLSession

    @available(iOS 12.0, *)
    public init(
        requestFactory: URLRequestFactory,
        middlewares: [Middleware] = [DefaultCodeValidationMiddleware(), DefaultLoggingMiddleware()],
        session: URLSession = .shared) {
        self.requestFactory = requestFactory
        self.middlewares = middlewares
        self.session = session
    }
}
