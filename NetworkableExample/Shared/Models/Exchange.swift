//
//  Exchange.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

import Foundation

/// An object abstract an exchange is an organized market where (especially) tradable cryptocurrencies are bought and sold.
struct Exchange: Codable, Equatable {
    let exchangeID, name, rank: String
    let exchangeURL: URL?

    enum CodingKeys: String, CodingKey {
        case exchangeID = "exchangeId"
        case name, rank
        case exchangeURL = "exchangeUrl"
    }
}

#if DEBUG
extension Exchange {
    /// A list of stubbed exchanges for previewing.
    static var stubbed: [Exchange] {
        let json = """
        [{"exchangeId":"binance","name":"Binance","rank":"1","exchangeUrl":"https://www.binance.com/"},{"exchangeId":"hitbtc","name":"HitBTC","rank":"2","exchangeUrl":"https://hitbtc.com/"},{"exchangeId":"crypto","name":"Crypto.com Exchange","rank":"3","exchangeUrl":"https://api.crypto.com/"}]
        """
        let decoder = JSONDecoder()
        return json
            .data(using: .utf8)
            .flatMap { try? decoder.decode([Exchange].self, from: $0) } ?? []
    }
}
#endif
