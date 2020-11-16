//
//  BalanceCard.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct BalanceCard: View {
    @ObservedObject var asset: BalanceDisplayInfo
    @Environment(\.fiatUoA) var fiatUoA: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: asset.symbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
                .opacity(0.33)
                .offset(x: -33, y: -33)
            VStack(alignment: .leading) {
                Text(asset.name).font(.headline)
                Spacer()
                Text("\(asset.balance, specifier: "%0.2f") \(asset.ticker)").font(.largeTitle)
                Spacer()
                HStack {
                    Text("\(asset.fiatBalance, specifier: "%0.2f") \(fiatUoA)")
                    Spacer()
                    Text("\(asset.btcBalance, specifier:"%0.6f") BTC")
                }.font(.footnote)
                Spacer()
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(RadialGradient(gradient: asset.color, center: .topLeading, startRadius: 66.6, endRadius: 313))
        .cornerRadius(13)
        .shadow(radius: 6.66)
    }
}
