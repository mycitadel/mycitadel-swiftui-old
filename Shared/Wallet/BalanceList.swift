//
//  WalletList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/17/20.
//

import SwiftUI
import CitadelKit

struct BalanceList: View {
    @State private var presentedSheet: PresentedSheet?
    @State private var errorMessage: String? = nil
    @State private var errorPresented: Bool = false

    var wallet: WalletContract

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .primaryAction
        #endif
    }
    
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
            ToolbarItemGroup(placement: toolbarPlacement) {
                Button(action: { presentedSheet = .walletDetails(wallet) }) {
                    Image(systemName: "info.circle")
                }

                Button(action: sync) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(item: $presentedSheet) { item in
            switch item {
            case .walletDetails(let w): WalletDetails(wallet: w)
            default: let _ = ""
            }
        }
        .alert(isPresented: $errorPresented, content: {
            Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .cancel())
        })
    }

    func sync() {
        do {
            try wallet.sync()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            errorPresented = true
        }
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        BalanceList(wallet: CitadelVault.embedded.contracts.first!)
    }
}
