//
//  RemoteCryptocurrencyMarketRepository.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

import Foundation
import Networkable
#if canImport(Combine)
import Combine
#endif

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
