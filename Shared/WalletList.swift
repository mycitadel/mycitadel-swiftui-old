//
//  WalletList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/17/20.
//

import SwiftUI
import MyCitadelKit

struct WalletList: View {
    var wallet: WalletContract

    var body: some View {
        List {
            ForEach(Array(wallet.balances.values), id: \.assetId) { balance in
                ZStack {
                    BalanceCard(balance: balance)
                        .frame(width: nil, height: 125, alignment: .center)
                        .padding(4)
                    NavigationLink(destination: TransactionView(wallet: wallet, assetId: balance.assetId)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle(wallet.name)
    }
}

struct WalletList_Previews: PreviewProvider {
    static var previews: some View {
        WalletList(wallet: CitadelVault.embedded.contracts.first!)
    }
}
