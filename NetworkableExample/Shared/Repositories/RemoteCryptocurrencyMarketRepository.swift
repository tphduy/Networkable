//
//  RemoteCryptocurrencyMarketRepository.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

#if canImport(Combine)
import Combine
#endif
import Networkable

/// An object provides methods for interacting with the crytocurrency market data in the remote database.
protocol RemoteCryptocurrencyMarketRepository {
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

/// An object provides methods for interacting with the crytocurrency market data in the remote database.
struct DefaultRemoteCryptocurrencyMarketRepository: RemoteCryptocurrencyMarketRepository {
    // MARK: Dependencies
    
    /// An ad-hoc network layer built on URLSession to perform an HTTP request.
    let provider: WebRepository
    
    // MARK: Init
    
    /// Initiate an object provides methods for interacting with the crytocurrency market data in the remote database.
    /// - Parameter provider: An ad-hoc network layer built on URLSession to perform an HTTP request.
    init(provider: WebRepository = DefaultWebRepository(requestBuilder: URLRequestBuilder(baseURL: URL(string: "https://api.coincap.io")))) {
        self.provider = provider
    }
    
    // MARK: RemoteCryptocurrencyMarketRepository
    func exchanges(promise: @escaping (Result<[Exchange], Error>) -> Void) -> URLSessionDataTask? {
        struct Datum: Codable { let data: [Exchange] }
        return provider.call(to: APIEndpoint.exchanges) { (result: Result<Datum, Error>) in
            promise(result.map({ $0.data }))
        }
    }
    
#if canImport(Combine)
    func exchanges() -> AnyPublisher<[Exchange], Error> {
        struct Datum: Codable { let data: [Exchange] }
        let result: AnyPublisher<Datum, Error> = provider.call(to: APIEndpoint.exchanges)
        return result
            .map(\.data)
            .eraseToAnyPublisher()
    }
#endif
    
    // MARK: Subtypes - APIEndpoint
    
    /// An object abstracts a HTTP request.
    enum APIEndpoint: Endpoint {
        /// Get all available exchanges.
        case exchanges
        
        var headers: [String: String]? { nil }
        
        var url: String { "/v2/exchanges" }
        
        var method: Method { .get }
        
        func body() throws -> Data? { nil }
    }
}
