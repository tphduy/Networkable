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
        let authorization = AuthorizationMiddleware(
            key: "Authorization",
            value: "Bearer bc162a58-874e-47b7-828d-552cbbe1d31f",
            place: .header)
        let statusCode = StatusCodeValidationMiddleware()
        let logging = LoggingMiddleware(type: .info, log: .network)
        let result = NetworkSession(
            requestBuilder: requestBuilder,
            middlewares: [
                authorization,
                statusCode,
                logging,
            ])
        return result
    }
}
