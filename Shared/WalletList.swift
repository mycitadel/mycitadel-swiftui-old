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
                    BalanceCard(asset: asset)
                        .frame(width: nil, height: 125, alignment: .center)
                        .padding(4)
                    NavigationLink(destination: TransactionView(wallet: wallet)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle(wallet.name)
    }
}

struct WalletList_Previews: PreviewProvider {
    @State static var dumb_data = DumbData().wallet

    static var previews: some View {
        WalletList(wallet: $dumb_data)
    }
}
