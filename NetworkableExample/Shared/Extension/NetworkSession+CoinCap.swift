//
//  NetworkSession+CoinCap.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Trần on 30/09/2022.
//

import Foundation
import Networkable

extension NetworkSession {
    
    /// An ad-hoc network layer that connects to the APIs at `https://api.coincap.io`.
    static var coincap: NetworkSession {
        let baseURL = URL(string: "https://api.coincap.io")
        let requestBuilder = URLRequestBuilder(baseURL: baseURL)
        let logging = LoggingMiddleware(type: .info)
        let middlewares = [logging]
        let result = NetworkSession(requestBuilder: requestBuilder, middlewares: middlewares)
        return result
    }
}
