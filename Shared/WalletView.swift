//
//  WalletView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

struct MasterView: View {
    var wallet: WalletContract

    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            BalanceList(wallet: wallet)
        } else {
            WalletView(wallet: wallet, selection: wallet.availableAssetIds.first ?? "")
        }
        #else
            BalanceList(wallet: wallet)
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
    var wallet: WalletContract
    @State var selection: String
    
    var body: some View {
        List {
            BalancePager(wallet: wallet, selection: $selection)
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
    static var wallet = CitadelVault.embedded.contracts.first!
    
    static var previews: some View {
        WalletView(wallet: wallet, selection: wallet.availableAssetIds.first ?? "")
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
