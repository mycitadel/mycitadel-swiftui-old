//
//  WalletView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct MasterView: View {
    @Binding var wallet: AccountDisplayInfo

    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            WalletList(wallet: $wallet)
        } else {
            WalletView(wallet: $wallet)
        }
        #else
            WalletList(wallet: $wallet)
        #endif
    }
}

struct WalletView: View {
    @Binding var wallet: AccountDisplayInfo
    @State private var selection: String = ""
    
    func filter() {
        
    }
    
    var body: some View {
        VStack {
            BalancePager(wallet: $wallet, selection: $selection)
                .frame(height: 200.0)
            TransactionView(wallet: wallet, ticker: selection == "" ? nil : selection)
        }
        .navigationTitle(wallet.name)
        .toolbar(content: {
            Button(action: filter) {
                Image(systemName: "calendar")
            }
        })
    }
}

struct WalletView_Previews: PreviewProvider {
    @State static var dumb = DumbData()

    static var previews: some View {
        WalletView(wallet: $dumb.wallet)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
