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
    let percentTotalVolume, volumeUsd: String?
    let tradingPairs: String
    let exchangeURL: URL?

    enum CodingKeys: String, CodingKey {
        case exchangeID = "exchangeId"
        case name, rank, percentTotalVolume, volumeUsd, tradingPairs
        case exchangeURL = "exchangeUrl"
    }
}
