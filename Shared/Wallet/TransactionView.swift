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
    var date: String {
        guard let date = transaction.date else {
            return transaction.createdAt
        }
        return Self.dateFormatter.string(from: date)
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
            Text(date).foregroundColor(.secondary).font(.footnote)
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
    
    private var assetIdModified: String? {
        assetId == CitadelVault.embedded.nativeAsset.id ? nil : assetId
    }
    private var operations: [TransferOperation] {
        do {
            let _ = try wallet.syncOperations()
        } catch {
            print(error.localizedDescription)
        }
        return wallet.operations.filter { $0.assetId == assetIdModified }
    }
    
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
        List(operations) { transaction in
            TransactionCell(transaction: transaction)
        }
        .navigationTitle("History")
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
