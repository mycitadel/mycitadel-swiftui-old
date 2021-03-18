//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import CitadelKit

struct BalancePager: View {
    var wallet: WalletContract
    @Binding var assetId: String

    #if os(iOS)
        var tabBarStyle = PageTabViewStyle()
    #elseif os(watchOS)
        var tabBarStyle = CarouselTabViewStyle()
    #else
        var tabBarStyle = DefaultTabViewStyle()
    #endif
    
    var body: some View {
        TabView(selection: $assetId) {
            ForEach(wallet.availableAssetIds, id: \.self) { assetId in
                NavigationLink(destination: AssetView(asset: CitadelVault.embedded.assets[assetId]!)) {
                    BalanceCard(wallet: wallet, assetId: assetId)
                        .tag(assetId)
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
        BalancePager(wallet: CitadelVault.embedded.contracts.first!, assetId: $selection)
            .previewDevice("iPhone 12 Pro")
            .frame(height: 100.0/*@END_MENU_TOKEN@*/)
            .environment(\.currencyUoA, "USD")
            .preferredColorScheme(.dark)
            
    }
}
