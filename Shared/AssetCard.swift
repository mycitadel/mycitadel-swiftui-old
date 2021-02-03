//
//  BalanceCard.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AssetCard: View {
    @ObservedObject var asset: AssetDisplayInfo
    @Environment(\.currencyUoA) var fiatUoA: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: asset.symbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
                .opacity(0.33)
                .offset(x: -33, y: -33)
            VStack(alignment: .leading) {
                Text(asset.name).font(.title)
                Spacer()
                HStack {
                    Text("\(asset.balance, specifier: "%.2f") \(asset.ticker)").font(.largeTitle)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(asset.fiatBalance, specifier: "%.2f") \(fiatUoA)")
                        Text("\(asset.btcBalance, specifier:"%.6f") BTC")
                    }.font(.footnote)
                }
                Spacer()
                HStack {
                    Spacer()
                    asset.issuerLabel.font(.headline)
                }
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(RadialGradient(gradient: asset.gradient, center: .topLeading, startRadius: 66.6, endRadius: 313))
        .cornerRadius(13)
        .shadow(radius: 6.66)
    }
}

struct AssetCard_Previews: PreviewProvider {
    static var previews: some View {
        AssetCard(asset: DumbData.init().data.assets[0])
    }
}
