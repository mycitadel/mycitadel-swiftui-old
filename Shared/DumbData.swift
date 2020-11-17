//
//  DumbData.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct DumbData {
    var wallet: WalletDisplayInfo
    var data: AppDisplayInfo

    init() {
        let btc = AssetDisplayInfo(
            withTicker: "BTC",
            name: "Bitcoin (onchain)",
            symbol: "bitcoinsign.circle.fill",
            category: .bitcoin
        )

        let shares = AssetDisplayInfo(
            withTicker: "PAN",
            name: "Pandora Core",
            symbol: "arrowtriangle.down.circle.fill",
            category: .security
        )

        let usdt = AssetDisplayInfo(
            withTicker: "USDT",
            name: "US Dollar Tether",
            symbol: "dollarsign.circle.fill",
            category: .stablecoin
        )

        let btcn = AssetDisplayInfo(
            withTicker: "BTC*",
            name: "Bitcoin (RGB)",
            symbol: "bitcoinsign.circle.fill",
            category: .bitcoin
        )

        let lnpbp = AssetDisplayInfo(
            withTicker: "LNP/BP",
            name: "LNP/BP Sponsor",
            symbol: "arrowtriangle.down",
            category: .collectible
        )

        self.wallet = WalletDisplayInfo(
            named: "Personal",
            havingAssets: [
                BalanceDisplayInfo(withAsset: btc, balance: 5.67484, btcRate: 1, fiatRate: 10_000),
                BalanceDisplayInfo(withAsset: btcn, balance: 1.34654, btcRate: 1, fiatRate: 10_000),
                BalanceDisplayInfo(withAsset: usdt, balance: 4_000, btcRate: 0.0001, fiatRate: 1.0),
                BalanceDisplayInfo(withAsset: shares, balance: 100_000, btcRate: 0.1, fiatRate: 1_000),
                BalanceDisplayInfo(withAsset: lnpbp, balance: 0.322, btcRate: 1, fiatRate: 10_000),
            ],
            transactions: [
                TransactionDisplayInfo(withAmount: 24456, directed: .Out, note: "Send to friend"),
                TransactionDisplayInfo(withAmount: 648245, directed: .Out, note: "Send to parent"),
                TransactionDisplayInfo(withAmount: 42574, directed: .In, note: "For a coffee"),
                TransactionDisplayInfo(withAmount: 52459, directed: .Out, note: "Glass of Prosecco"),
                TransactionDisplayInfo(withAmount: 29487, directed: .In, note: "Testing Lightning")
            ]
        )

        let company = WalletDisplayInfo(
            named: "My company",
            havingAssets: [
                BalanceDisplayInfo(withAsset: btc, balance: 5.67484, btcRate: 1, fiatRate: 10_000),
                BalanceDisplayInfo(withAsset: btcn, balance: 1.34654, btcRate: 1, fiatRate: 10_000),
                BalanceDisplayInfo(withAsset: usdt, balance: 4_000, btcRate: 0.0001, fiatRate: 1.0),
            ],
            transactions: [
                TransactionDisplayInfo(withAmount: 24456, directed: .Out, note: "Send to friend"),
                TransactionDisplayInfo(withAmount: 648245, directed: .Out, note: "Send to parent"),
                TransactionDisplayInfo(withAmount: 42574, directed: .In, note: "For a coffee"),
                TransactionDisplayInfo(withAmount: 52459, directed: .Out, note: "Glass of Prosecco"),
                TransactionDisplayInfo(withAmount: 29487, directed: .In, note: "Testing Lightning")
            ]
        )
        
        let keyring1 = KeyringDisplayInfo(named: "First signature")
        let keyring2 = KeyringDisplayInfo(named: "Second signature")

        self.data = AppDisplayInfo(wallets: [self.wallet, company], keyrings: [keyring1, keyring2], assets: [btc, btcn, shares, usdt, lnpbp])
    }
}
