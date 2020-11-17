//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct BalancePager: View {
    @Binding var wallet: WalletDisplayInfo

    #if os(iOS)
        private var tabBarStyle = PageTabViewStyle()
    #elseif os(watchOS)
        private var tabBarStyle = CarouselTabViewStyle()
    #else
        private var tabBarStyle = DefaultTabViewStyle()
    #endif

    init(withWallet wallet: Binding<WalletDisplayInfo>) {
        self._wallet = wallet
    }
    
    var body: some View {
        TabView {
            ForEach(wallet.assets, id: \.ticker) { asset in
                BalanceCard(asset: asset)
            }
            .padding()
        }
        .tabViewStyle(tabBarStyle)
    }
}


struct BalancePager_Previews: PreviewProvider {
    @State static var dumb_data = DumbData().wallet
    
    static var previews: some View {
        BalancePager(withWallet: $dumb_data)
            .previewDevice("iPhone 12 Pro")
            .frame(height: 100.0/*@END_MENU_TOKEN@*/)
            .environment(\.fiatUoA, "USD")
            .preferredColorScheme(.dark)
            
    }
}
