//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct BalancePager: View {
    @Binding var wallet: AccountDisplayInfo
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
            ForEach(wallet.assets, id: \.ticker) { asset in
                BalanceCard(asset: asset)
                    .tag(asset.ticker)
            }
            .padding()
        }
        .tabViewStyle(tabBarStyle)
    }
}


struct BalancePager_Previews: PreviewProvider {
    @State static var dumb = DumbData()
    @State static var selection: String = ""
    
    static var previews: some View {
        BalancePager(wallet: $dumb.wallet, selection: $selection)
            .previewDevice("iPhone 12 Pro")
            .frame(height: 100.0/*@END_MENU_TOKEN@*/)
            .environment(\.currencyUoA, "USD")
            .preferredColorScheme(.dark)
            
    }
}
