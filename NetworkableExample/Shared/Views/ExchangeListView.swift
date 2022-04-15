//
//  ExchangeListView.swift
//  Shared
//
//  Created by Duy Tran on 15/04/2022.
//

import SwiftUI

/// A view that displays a list of exchanges.
struct ExchangeListView: View {
    // MARK: Dependencies
    
    /// An object that manages the crytocurrency market data and apply business rules to achive a use case.
    @Environment(\.cryptocurrencyMarketUseCase) var cryptocurrencyMarketUseCase
    
    /// A list of available exchanges.
    @State private(set) var exchanges: [Exchange] = []
    
    // MARK: View
    
    var body: some View {
        List(exchanges, rowContent: ExchangeRow.init(exchange:))
            .navigationTitle(NSLocalizedString("Exchanges", comment: "Exchanges"))
            .onAppear(perform: reloadDataIfNeeded)
    }
    
    // MARK: Side Effects
    
    /// Reload all data if data is empty.
    func reloadDataIfNeeded() {
        guard exchanges.isEmpty else { return }
        reloadData()
    }
    
    /// Reload all data.
    func reloadData() {
        cryptocurrencyMarketUseCase.exchanges { (result: Result<[Exchange], Error>) in
            exchanges = (try? result.get()) ?? []
        }
    }
}

#if DEBUG
struct ExchangeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExchangeListView()
                .environment(\.cryptocurrencyMarketUseCase, StubbedCryptocurrencyMarketUseCase())
        }
    }
}
#endif
