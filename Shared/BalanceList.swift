//
//  WalletList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/17/20.
//

import SwiftUI
import MyCitadelKit

struct BalanceList: View {
    var wallet: WalletContract

    var body: some View {
        List {
            ForEach(wallet.availableAssetIds, id: \.self) { assetId in
                ZStack {
                    BalanceCard(wallet: wallet, assetId: assetId)
                        .frame(width: nil, height: 125, alignment: .center)
                        .padding(4)
                    NavigationLink(destination: TransactionView(wallet: wallet, assetId: assetId)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle(wallet.name)
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        BalanceList(wallet: CitadelVault.embedded.contracts.first!)
    }
}
