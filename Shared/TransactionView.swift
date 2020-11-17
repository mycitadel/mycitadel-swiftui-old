//
//  TransactionView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

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
    @ObservedObject var wallet: AccountDisplayInfo
    var ticker: String? = nil

    var body: some View {
        List(wallet.transactions.filter { ticker == nil || $0.asset.ticker == ticker }) { transaction in
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
    @State static var dumb = DumbData()
    @State static var ticker: String = ""

    static var previews: some View {
        TransactionView(wallet: dumb.wallet)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
