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
            WalletView(wallet: $wallet, selection: wallet.assets.first?.ticker ?? "")
        }
        #else
            WalletList(wallet: $wallet)
        #endif
    }
}

struct SendReceiveView: View {
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {}) {
                Label("Invoice", systemImage: "scroll")
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .foregroundColor(.white)
            }
            .background(Color.accentColor)
            .cornerRadius(24)
            
            Spacer()

            Button(action: {}) {
                Label("Pay", systemImage: "arrow.up.doc.on.clipboard")
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .foregroundColor(.white)
            }
            .background(Color.accentColor)
            .cornerRadius(24)

            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}

struct WalletView: View {
    @Binding var wallet: AccountDisplayInfo
    @State var selection: String
    
    var body: some View {
        List {
            BalancePager(wallet: $wallet, selection: $selection)
                .frame(height: 200.0)
            Section(header: SendReceiveView()) {
                ForEach(wallet.transactions.filter { selection == "" || $0.asset.ticker == selection }) { transaction in
                    TransactionCell(transaction: transaction)
                }
            }
        }
        .navigationTitle(wallet.name)
        .toolbar(content: {
            Button(action: { }) {
                Image(systemName: "calendar")
            }
        })
    }
}

struct WalletView_Previews: PreviewProvider {
    @State static var dumb = DumbData()

    static var previews: some View {
        WalletView(wallet: $dumb.wallet, selection: dumb.wallet.assets.first?.ticker ?? "")
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
