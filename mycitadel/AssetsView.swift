//
//  AssetsView.swift
//  mycitadel
//
//  Created by Maxim Orlovsky on 16-01-2020.
//  Copyright © 2020 Datagnition. All rights reserved.
//

import SwiftUI

struct AssetDisplayInfo {
    let name: String
    let color: RadialGradient
    let balance: UInt64
    let rate: Float32
    let currency: String
}

enum TransactionDirection {
    case In
    case Out
}

struct TransactionDisplayInfo: Identifiable {
    let id: UUID = UUID()
    let direction: TransactionDirection
    let comment: String
    let date: Date
    let amount: UInt64
    let rate: Float32
    let currency: String
}


let assets: [AssetDisplayInfo] = [
    AssetDisplayInfo(name: "Bitcoin",
                     color: RadialGradient(gradient: Gradient(colors: [.orange, .yellow]), center: .topLeading, startRadius: 66.6, endRadius: 313),
                     balance: 1_000_000, rate: 10_000, currency: "$"),
    AssetDisplayInfo(name: "Bitcoin Tether",
                     color: RadialGradient(gradient: Gradient(colors: [.red, .orange]), center: .topLeading, startRadius: 66.6, endRadius: 313),
                     balance: 100_000, rate: 10_000, currency: "$")
]

let transactions: [TransactionDisplayInfo] = [
    TransactionDisplayInfo(direction: .Out, comment: "Send to friend", date: Date(),
                           amount: 24456, rate: 7863, currency: "$"),
    TransactionDisplayInfo(direction: .Out, comment: "Send to parent", date: Date(),
                           amount: 648245, rate: 7863, currency: "$"),
    TransactionDisplayInfo(direction: .In, comment: "For a coffee", date: Date(),
                           amount: 42574, rate: 7863, currency: "$"),
    TransactionDisplayInfo(direction: .Out, comment: "Glass of Prosecco", date: Date(),
                           amount: 52459, rate: 7863, currency: "$"),
    TransactionDisplayInfo(direction: .In, comment: "Testing Lightning", date: Date(),
                           amount: 29487, rate: 7863, currency: "$")
]


struct AssetsView<Card: View>: View {
    var viewControllers: [UIHostingController<Card>]
    @State var currentPage = 0
        
    init(_ views: [Card]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }
    
    var body: some View {
        VStack {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
                .frame(height: 166.0)
                
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
                .padding(0).frame(height: 13)
            List(transactions) { transaction in
                TransactionCell(transaction: transaction)
            }
        }
    }
}

struct AssetCard: View {
    let asset: AssetDisplayInfo
    let brief: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                if brief {
                    HStack {
                        Text(asset.name).font(.headline)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("\(asset.balance)").font(.title)
                        Spacer()
                    }
                }
                if !brief {
                    Text(asset.name).font(.headline)
                    Spacer()
                    Text("\(asset.balance)").font(.largeTitle)
                    Spacer()
                    HStack {
                        Text("\(asset.currency) \(Int(Float(asset.balance) / asset.rate))")
                        Spacer()
                        Text("\(Float(asset.balance) / 100_000_000) BTC")
                    }.font(.footnote)
                    Spacer()
                }
            }.foregroundColor(.black)
        }
        .padding()
        .background(asset.color)
        .cornerRadius(13)
        .shadow(radius: 6.66)
    }
}

struct TransactionCell: View {
    let transaction: TransactionDisplayInfo
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.\(transaction.direction == .Out ? "up" : "down").circle.fill")
                .font(.title)
                .foregroundColor(transaction.direction == .Out ?.red : .blue)
                .padding()
            VStack(alignment: .leading) {
                Text(transaction.comment).font(.headline)
                Text("\(transaction.date, formatter: Self.dateFormatter)").font(.subheadline)
            }
            Spacer()
            Text("\(transaction.amount) s")
        }
    }
}

struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView(assets.map { AssetCard(asset: $0, brief: false)
            .frame(minWidth: 113, idealWidth: 266, maxWidth: 331, minHeight: 131, idealHeight: 166, maxHeight: 213)
            .padding() })
    }
}
