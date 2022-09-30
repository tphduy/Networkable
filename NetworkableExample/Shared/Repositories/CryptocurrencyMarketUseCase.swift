//
//  CryptocurrencyMarketUseCase.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

/// An object that manages the crytocurrency market data and apply business rules to achive a use case.
///
/// The use cases situated on top of models and the “ports” for the data access layer (used for dependency inversion, usually Repository interfaces), retrieve and store domain models by using either repositories or other use cases.
protocol CryptocurrencyMarketUseCase {
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

/// An object that manages the crytocurrency market data and apply business rules to achive a use case.
final class DefaultCryptocurrencyMarketUseCase: CryptocurrencyMarketUseCase {
    // MARK: Dependencies
    
    /// An object provides methods for interacting with the crytocurrency market data in the remote database.
    let remoteCryptocurrencyMarketRepository: RemoteCryptocurrencyMarketRepository
    
    // MARK: Init
    
    /// Initiate an object that manages the crytocurrency market data and apply business rules to achive a use case.
    /// - Parameter remoteCryptocurrencyMarketRepository: An object provides methods for interacting with the crytocurrency market data in the remote database.
    init(remoteCryptocurrencyMarketRepository: RemoteCryptocurrencyMarketRepository = DefaultRemoteCryptocurrencyMarketRepository()) {
        self.remoteCryptocurrencyMarketRepository = remoteCryptocurrencyMarketRepository
    }
    
    // MARK: CryptocurrencyMarketUseCase
    
    @discardableResult
    func exchangesTask(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        remoteCryptocurrencyMarketRepository.exchangesTask(promise: promise)
    }
    
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchangesPublisher() -> AnyPublisher<[Exchange], Error> {
        remoteCryptocurrencyMarketRepository.exchangesPublisher()
    }
    
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchanges() async throws -> [Exchange] {
        try await remoteCryptocurrencyMarketRepository.exchanges()
    }
}

#if DEBUG
/// A stubbed implementation of `CryptocurrencyMarketUseCase` for preview.
final class StubbedCryptocurrencyMarketUseCase: CryptocurrencyMarketUseCase {
    // MARK: CryptocurrencyMarketUseCase
    
    func exchangesTask(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        promise(.success(.stubbed))
        return nil
    }
    
    @available(macOS 10.15, macCatalyst 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchangesPublisher() -> AnyPublisher<[Exchange], Error> {
        Future<[Exchange], Error> { (promise) in
            promise(.success(.stubbed))
        }
        .eraseToAnyPublisher()
    }
    
    @available(macOS 12.0, macCatalyst 15.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func exchanges() async throws -> [Exchange] {
        .stubbed
    }
}
#endif
