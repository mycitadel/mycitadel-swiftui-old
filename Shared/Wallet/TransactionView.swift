//
//  TransactionView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

struct TransactionCell: View {
    var transaction: TransferOperation
    var asset: Asset {
        if let assetId = transaction.assetId {
            return CitadelVault.embedded.assets[assetId]!
        } else {
            return CitadelVault.embedded.nativeAsset
        }
    }
    var amount: Double {
        asset.amount(fromAtoms: transaction.value)
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.\(transaction.isOutcoming ? "up" : "down").circle.fill")
                .font(.title)
                .foregroundColor(transaction.isOutcoming ?.red : .blue)
                .padding([.top, .bottom, .trailing], 10)
            Text("\(transaction.createdAt, formatter: Self.dateFormatter)").foregroundColor(.secondary).font(.footnote)
            Spacer()
            HStack {
                Text("\(amount)")
                Text(asset.ticker).foregroundColor(.secondary)
            }
        }
    }
}

struct TransactionView: View {
    var wallet: WalletContract
    var assetId: String = CitadelVault.embedded.nativeAsset.id

    @State private var scannedInvoice: Invoice? = nil
    @State private var scannedString: String = ""
    @State var presentedSheet: PresentedSheet?
    private let placement: ToolbarItemPlacement = {
        #if os(iOS)
        return ToolbarItemPlacement.navigationBarLeading
        #else
        return ToolbarItemPlacement.primaryAction
        #endif
    }()
    
    var body: some View {
        List(wallet.operations.filter { $0.assetId == assetId }) { transaction in
            TransactionCell(transaction: transaction)
        }
        .toolbar {
            ToolbarItemGroup(placement: placement) {
                Button("Receive") { presentedSheet = .invoice(wallet, assetId) }
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
                Spacer()
                Button("Send") { presentedSheet = .scan("invoice", .invoice) }
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
            }
        }
        .sheet(item: $presentedSheet) { item in
            switch item {
            case .invoice(_, _): InvoiceCreate(wallet: wallet, assetId: assetId)
            case .scan(let name, let category):
                Import(importName: name, category: category, invoice: $scannedInvoice, dataString: $scannedString, wallet: wallet)
            default: let _ = ()
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(wallet: CitadelVault.embedded.contracts.first!,
                        assetId: CitadelVault.embedded.assets.values.first!.id)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
