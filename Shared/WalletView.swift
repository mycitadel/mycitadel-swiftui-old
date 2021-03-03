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
            WalletView(wallet: wallet)
        }
        #else
            BalanceList(wallet: wallet)
        #endif
    }
}

struct SendReceiveView: View {
    @Binding var presentedSheet: PresentedSheet?
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { presentedSheet = .invoice(nil, nil) }) {
                Label("Invoice", systemImage: "scroll")
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .foregroundColor(.white)
            }
            .background(Color.accentColor)
            .cornerRadius(24)
            
            Spacer()

            Button(action: { presentedSheet = .scan("invoice", .invoice) }) {
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
    @State var assetId: String = CitadelVault.embedded.nativeAsset.id
    @State private var presentedSheet: PresentedSheet?
    @State private var errorMessage: String? = nil
    @State private var scannedInvoice: Invoice? = nil
    
    var body: some View {
        List {
            BalancePager(wallet: wallet, assetId: $assetId)
                .frame(height: 200.0)
            Section(header: SendReceiveView(presentedSheet: $presentedSheet)) {
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
                ForEach(wallet.transactions.filter { assetId == "" || $0.asset.ticker == assetId }) { transaction in
                    TransactionCell(transaction: transaction)
                }
            }
        }
        .navigationTitle(wallet.name)
        .toolbar {
            ToolbarItem {
                Button(action: sync) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(item: $presentedSheet) { item in
            switch item {
            case .invoice(_, _): CreateInvoice(wallet: wallet, assetId: assetId)
            case .scan(let name, let category):
                Import(importName: name, category: category, invoice: $scannedInvoice)
                    .onDisappear {
                        if let scannedInvoice = scannedInvoice {
                            presentedSheet = .pay(wallet, scannedInvoice)
                        }
                    }
            case .pay(_, let invoice): PaymentView(invoice: invoice)
            }
        }
    }
    
    func sync() {
        do {
            try wallet.sync()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var wallet = CitadelVault.embedded.contracts.first!
    
    static var previews: some View {
        WalletView(wallet: wallet)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
