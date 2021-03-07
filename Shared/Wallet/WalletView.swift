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
        VStack {
            HStack {
                Button(action: { presentedSheet = .invoice(nil, nil) }) {
                    Text("Invoice")
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .foregroundColor(.white)
                }
                .background(Color.accentColor)
                .cornerRadius(24)

                Button(action: { presentedSheet = .scan("invoice", .invoice) }) {
                    Label("Pay", systemImage: "arrow.up.doc.on.clipboard")
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .foregroundColor(.white)
                }
                .background(Color.accentColor)
                .cornerRadius(24)

                Button(action: { presentedSheet = .scan("consignment", .consignment) }) {
                    Text("Accept")
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .foregroundColor(.white)
                }
                .background(Color.accentColor)
                .cornerRadius(24)
            }
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
    @State private var scannedString: String = ""
    @State private var status: String? = nil
    @State private var statusPresented: Bool = false

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .primaryAction
        #endif
    }

    var body: some View {
        List {
            BalancePager(wallet: wallet, assetId: $assetId)
                .frame(height: 200.0)
            Section(header: SendReceiveView(presentedSheet: $presentedSheet)) {
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
                ForEach(wallet.operations.filter { assetId == "" || $0.assetId == assetId }) { transaction in
                    TransactionCell(transaction: transaction)
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
            case .invoice(_, _): InvoiceCreate(wallet: wallet, assetId: assetId)
            case .scan(let name, .invoice):
                Import(importName: name, category: .invoice, invoice: $scannedInvoice, dataString: $scannedString, wallet: wallet)
            case .scan(let name, .consignment):
                Import(importName: name, category: .consignment, invoice: $scannedInvoice, dataString: $scannedString)
                    .onDisappear {
                        do {
                            status = try wallet.accept(consignment: scannedString)
                        } catch {
                            status = error.localizedDescription
                        }
                    }
            case .walletDetails(let w): WalletDetails(wallet: w)
            default: let _ = ""
            }
        }
        .alert(isPresented: $statusPresented, content: {
            Alert(title: Text("Result"), message: Text(status ?? ""), dismissButton: .cancel())
        })
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
