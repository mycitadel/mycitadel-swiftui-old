//
//  TransactionView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

struct TransactionCell: View {
    @ObservedObject var transaction: TransactionDisplayInfo
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.\(transaction.direction == .Out ? "up" : "down").circle.fill")
                .font(.title)
                .foregroundColor(transaction.direction == .Out ?.red : .blue)
                .padding([.top, .bottom, .trailing], 10)
            VStack(alignment: .leading) {
                Text(transaction.comment).font(.headline)
                Text("\(transaction.date, formatter: Self.dateFormatter)").foregroundColor(.secondary).font(.footnote)
            }
            Spacer()
            HStack {
                Text("\(transaction.amount)")
                Text(transaction.asset.ticker).foregroundColor(.secondary)
            }
        }
    }
}

struct TransactionView: View {
    var wallet: WalletContract
    var assetId: String? = nil

    var body: some View {
        List(wallet.transactions.filter { assetId == nil || $0.asset.id == assetId }) { transaction in
            TransactionCell(transaction: transaction)
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button("Receive") { }
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
                Button("Send") { }
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(13)
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(wallet: CitadelVault.embedded.contracts.first!)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
