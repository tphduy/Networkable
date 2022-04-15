//
//  ExchangeRow.swift
//  NetworkableExample (iOS)
//
//  Created by Duy Tran on 15/04/2022.
//

import SwiftUI

/// A view that dislpays an exchange horicontally.
struct ExchangeRow: View {
    // MARK: Dependencies
    
    /// An object abstract an exchange.
    @State private(set) var exchange: Exchange
    
    // MARK: View
    
    var body: some View {
        HStack {
            exchange.rank.map { Text($0) }
            exchange.name.map { Text($0) }
            Spacer()
            exchange.exchangeURL.map { _ in
                Text(NSLocalizedString("Trade", comment: "Trade"))
                    .bold()
                    .foregroundColor(.blue)
            }
        }
    }
}

#if DEBUG
struct ExchangeRow_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeRow(exchange: .stubbed)
    }
}
#endif
