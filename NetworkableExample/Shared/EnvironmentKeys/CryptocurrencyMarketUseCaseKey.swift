//
//  CryptocurrencyMarketUseCaseKey.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

import SwiftUI

/// A key for accessing the `CryptocurrencyMarketUseCase`  in the environment.
struct CryptocurrencyMarketUseCaseKey: EnvironmentKey {
    // MARK: EnvironmentKey
    
    static var defaultValue: CryptocurrencyMarketUseCase = DefaultCryptocurrencyMarketUseCase()
}

extension EnvironmentValues {
    /// An object that manages the crytocurrency market data and apply business rules to achive a use case.
    var cryptocurrencyMarketUseCase: CryptocurrencyMarketUseCase {
        get { self[CryptocurrencyMarketUseCaseKey.self] }
        set { self[CryptocurrencyMarketUseCaseKey.self] = newValue }
    }
}
