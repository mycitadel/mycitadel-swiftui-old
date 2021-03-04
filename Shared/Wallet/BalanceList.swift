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
            ForEach(wallet.availableAssets, id: \.id) { asset in
                ZStack {
                    BalanceCard(wallet: wallet, assetId: asset.id)
                        .frame(width: nil, height: 125, alignment: .center)
                        .padding(4)
                    NavigationLink(destination: TransactionView(wallet: wallet, assetId: asset.id)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle(wallet.name)
        .toolbar {
            ToolbarItem {
                Button(action: { try? wallet.sync() }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        BalanceList(wallet: CitadelVault.embedded.contracts.first!)
    }
}
