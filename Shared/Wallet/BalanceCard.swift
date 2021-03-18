//
//  BalanceCard.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import CitadelKit

struct BalanceCard: View {
    var wallet: WalletContract?
    var assetId: String = CitadelVault.embedded.network.nativeAssetId()
    var balance: Balance {
        if let wallet = wallet {
            return wallet.balance(of: assetId)!
        } else {
            return asset.balance
        }
    }
    var asset: Asset {
        CitadelVault.embedded.assets[assetId]!
    }
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
                    Text("\(balance.total) \(asset.ticker)").font(.largeTitle)
                    /*
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(balance.fiatBalance, specifier: "%.2f") \(fiatUoA)")
                        Text("\(balance.btcBalance, specifier:"%.6f") BTC")
                    }.font(.footnote)
                    */
                }
                Spacer()
                HStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text(asset.authenticity.issuer?.name ?? "Unknown")
                        Image(systemName: asset.authenticity.symbol)
                            .foregroundColor(asset.authenticity.color)
                            .shadow(color: .white, radius: 3, x: 0, y: 0)
                    }
                    .font(.headline)
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
        BalanceCard()
    }
}
