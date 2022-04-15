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
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask?
    
#if canImport(Combine)
    /// Get all available exchanges.
    /// - Returns: A publisher emits result of a request.
    func exchanges() -> AnyPublisher<[Exchange], Error>
#endif
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
    
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        remoteCryptocurrencyMarketRepository.exchanges(promise: promise)
    }
    
#if canImport(Combine)
    func exchanges() -> AnyPublisher<[Exchange], Error> {
        remoteCryptocurrencyMarketRepository.exchanges()
    }
#endif
}
