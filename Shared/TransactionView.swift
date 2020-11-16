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
            Text("\(transaction.amount) sat")
        }
    }
}

struct TransactionView: View {
    @ObservedObject var wallet: WalletDisplayInfo
    
    var body: some View {
        List(wallet.transactions) { transaction in
            TransactionCell(transaction: transaction)
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    @State static var dumb_data = DumbData().wallet

    static var previews: some View {
        TransactionView(wallet: dumb_data)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
