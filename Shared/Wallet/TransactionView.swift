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
    var asset: Asset {
        CitadelVault.embedded.assets[assetId]!
    }

    private struct AddressBalance: Identifiable {
        public var id: String { address }
        public let address: String
        public var amount: Double
        public var utxo: [(OutPoint, Double)]
    }
    
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
    private var addressBalances: [AddressBalance] {
        Array((wallet.balance(of: assetId)?.unspentAllocations.reduce(into: [String: AddressBalance]()) { ( balances: inout [String: AddressBalance], allocation) in
            guard let address = allocation.address else { return }
            var balance = balances[address] ?? AddressBalance(address: address, amount: 0, utxo: [])
            balance.amount += allocation.amount
            balance.utxo.append((allocation.outpoint, allocation.amount))
            balances[address] = balance
        } ?? [:]).values)
    }
    
    enum SelectedTab: Hashable {
        case history, balance
        
        var title: String {
            switch self {
            case .balance: return "Balance"
            case .history: return "History"
            }
        }
    }
    
    @State private var selectedTab: SelectedTab = .history
    @State private var scannedInvoice: Invoice? = nil
    @State private var scannedString: String = ""
    @State var presentedSheet: PresentedSheet?
    
    var body: some View {
        List{
            if selectedTab == .history {
                ForEach(operations) { transaction in
                    TransactionCell(transaction: transaction)
                }
            } else {
                ForEach(addressBalances) { balance in
                    Section(header: Text("Address")) {
                        Copyable(text: balance.address) {
                            BechBrief(text: balance.address)
                        }
                        DetailsCell(title: "Balance:", details: "\(balance.amount) \(asset.ticker)", clipboardCopy: true)
                        ForEach(balance.utxo, id: \.0) { (outpoint, amount) in
                            HStack(alignment: .center) {
                                VStack(alignment: .leading) {
                                    Text(outpoint.txid)
                                        .font(.subheadline)
                                        .truncationMode(.middle)
                                        .lineLimit(1)
                                    HStack(alignment: .lastTextBaseline) {
                                        Text("Output number:").font(.caption).foregroundColor(.secondary)
                                        Text("\(outpoint.vout)").font(.subheadline)
                                    }
                                }
                                Spacer()
                                Text("\(amount) \(asset.ticker)").font(.subheadline)
                            }.padding(.leading)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(selectedTab.title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Receive") { presentedSheet = .invoice(wallet, assetId) }
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Send") { presentedSheet = .scan("invoice", .invoice) }
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
            }
            ToolbarItem(placement: .principal) {
                Picker(selection: $selectedTab, label: EmptyView()) {
                    Text("History").tag(SelectedTab.history)
                    Text("Balance").tag(SelectedTab.balance)
                }.pickerStyle(SegmentedPickerStyle())
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
