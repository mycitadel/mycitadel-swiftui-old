//
//  WalletList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/17/20.
//

import SwiftUI

struct WalletList: View {
    @Binding var wallet: AccountDisplayInfo

    var body: some View {
        List {
            ForEach(wallet.assets, id: \.ticker) { asset in
                ZStack {
                    AssetCard(asset: asset)
                        .frame(width: nil, height: 125, alignment: .center)
                        .padding(4)
                    NavigationLink(destination: TransactionView(wallet: wallet, ticker: asset.ticker)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle(wallet.name)
    }
}

struct WalletList_Previews: PreviewProvider {
    @State static var dumb = DumbData()

    static var previews: some View {
        WalletList(wallet: $dumb.wallet)
    }
}
