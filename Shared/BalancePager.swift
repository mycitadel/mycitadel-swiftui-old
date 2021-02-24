//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

struct BalancePager: View {
    var wallet: WalletContract
    @Binding var selection: String

    #if os(iOS)
        var tabBarStyle = PageTabViewStyle()
    #elseif os(watchOS)
        var tabBarStyle = CarouselTabViewStyle()
    #else
        var tabBarStyle = DefaultTabViewStyle()
    #endif
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(wallet.balances.values), id: \.assetId) { balance in
                NavigationLink(destination: AssetView(asset: CitadelVault.embedded.assets[balance.assetId]!)) {
                    BalanceCard(balance: balance)
                        .tag(balance.assetId)
                }
            }
            .padding()
        }
        .tabViewStyle(tabBarStyle)
    }
}


struct BalancePager_Previews: PreviewProvider {
    @State static var selection: String = ""
    
    static var previews: some View {
        BalancePager(wallet: CitadelVault.embedded.contracts.first!, selection: $selection)
            .previewDevice("iPhone 12 Pro")
            .frame(height: 100.0/*@END_MENU_TOKEN@*/)
            .environment(\.currencyUoA, "USD")
            .preferredColorScheme(.dark)
            
    }
}
