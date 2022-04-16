//
//  CryptocurrencyMarketUseCase.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

/// An object that manages the crytocurrency market data and apply business rules to achive a use case.
///
/// The use cases situated on top of models and the “ports” for the data access layer (used for dependency inversion, usually Repository interfaces), retrieve and store domain models by using either repositories or other use cases.
protocol CryptocurrencyMarketUseCase {
    /// Get all available exchanges.
    /// - Parameter promise: A promise to be fulfilled with a result represents either a success or a failure. The success value is the cart data of a store.
    /// - Returns: A URL session task that returns downloaded data directly to the app in memory.
    @discardableResult
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask?
    
    /// Get all available exchanges.
    /// - Returns: An asynchronously-delivered list of exchanges.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func exchanges() async throws -> [Exchange]
    
    /// Get all available exchanges.
    /// - Returns: A publisher emits result of a request.
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func exchanges() -> AnyPublisher<[Exchange], Error>
}

/// An object that manages the crytocurrency market data and apply business rules to achive a use case.
struct DefaultCryptocurrencyMarketUseCase: CryptocurrencyMarketUseCase {
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
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        remoteCryptocurrencyMarketRepository.exchanges(promise: promise)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func exchanges() async throws -> [Exchange] {
        try await remoteCryptocurrencyMarketRepository.exchanges()
    }
    
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func exchanges() -> AnyPublisher<[Exchange], Error> {
        remoteCryptocurrencyMarketRepository.exchanges()
    }
}

#if DEBUG

/// A stubbed implementation of `CryptocurrencyMarketUseCase` for preview.
struct StubbedCryptocurrencyMarketUseCase: CryptocurrencyMarketUseCase {
    // MARK: CryptocurrencyMarketUseCase
    
    @discardableResult
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        promise(.success(.stubbed))
        return nil
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func exchanges() async throws -> [Exchange] {
        .stubbed
    }
    
    @available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)@available(iOS 13.0, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    func exchanges() -> AnyPublisher<[Exchange], Error> {
        Future<[Exchange], Error> { promise in
            promise(.success(.stubbed))
        }
        .eraseToAnyPublisher()
    }
}
#endif
