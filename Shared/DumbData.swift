//
//  DumbData.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

extension TransactionDisplayInfo {
    static let DUMB_NOTES = [
        "Send to friend",
        "Send to parent",
        "For a coffee",
        "AliExpress",
        "To exchange",
        "Lunch",
        "BBQ",
        "Grocery shopping",
        "Donation to LNP/BP",
        "HCPP'19 bar",
        "Car rental",
        "House clearing",
        "Petrol",
        "Traint ticket to Zug"
    ]

    public convenience init(randomWithAsset asset: AssetDisplayInfo) {
        let amount = Float.random(in: 0.95...166.6) / asset.fiatRate
        let direction = Bool.random() ? TransactionDirection.In : TransactionDirection.Out
        let note = Self.DUMB_NOTES.randomElement()!
        self.init(withAmount: amount, ofAsset: asset, directed: direction, note: note)
    }
}

extension BalanceDisplayInfo {
    public convenience init(randomWithAsset asset: AssetDisplayInfo, useSmallBalance isSmall: Bool = false) {
        let balance = Float.random(in: isSmall ? 0.95...166.6 : 1000...10000) / asset.fiatRate
        self.init(withAsset: asset, balance: balance)
    }
}

extension AccountDisplayInfo {
    public convenience init(randomWithAssets assets: [AssetDisplayInfo], named name: String,
                            contract: AccountContract, useSmallBalance isSmall: Bool = false) {
        let balances = assets.map { asset in
            BalanceDisplayInfo(randomWithAsset: asset, useSmallBalance: isSmall)
        }
        let transactions = (0...Int.random(in: 4...13)).map { _ in
            TransactionDisplayInfo(randomWithAsset: assets.randomElement()!)
        }
        self.init(named: name, havingAssets: balances, transactions: transactions, contract: contract)
    }
}

struct DumbData {
    var wallet: AccountDisplayInfo
    var data: AppDisplayInfo

    init() {
        let btc = AssetDisplayInfo(
            withTicker: "BTC",
            name: "Bitcoin (onchain)",
            symbol: "bitcoinsign.circle.fill",
            category: .bitcoin,
            btcRate: 1,
            fiatRate: 10_000
        )

        let shares = AssetDisplayInfo(
            withTicker: "PAN",
            name: "Pandora Core",
            symbol: "arrowtriangle.down.circle.fill",
            category: .security,
            btcRate: 0.1,
            fiatRate: 1_000
        )

        let usdt = AssetDisplayInfo(
            withTicker: "USDT",
            name: "US Dollar Tether",
            symbol: "dollarsign.circle.fill",
            category: .stablecoin,
            btcRate: 0.0001,
            fiatRate: 1.0
        )

        let btcn = AssetDisplayInfo(
            withTicker: "BTC*",
            name: "Bitcoin (RGB)",
            symbol: "bitcoinsign.circle.fill",
            category: .bitcoin,
            btcRate: 1,
            fiatRate: 10_000
        )

        let lnpbp = AssetDisplayInfo(
            withTicker: "LNP/BP",
            name: "LNP/BP Sponsor",
            symbol: "arrowtriangle.down",
            category: .collectible,
            btcRate: 1,
            fiatRate: 10_000
        )

        self.wallet = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt, lnpbp],
            named: "Current",
            contract: .current(CurrentContract()),
            useSmallBalance: true
        )

        let savings = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt, shares, lnpbp],
            named: "Savings",
            contract: .saving(.musig)
        )

        let family = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt],
            named: "Family",
            contract: .current(CurrentContract())
        )
        
        let company = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt],
            named: "My company",
            contract: .current(CurrentContract())
        )
        
        let lightning = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt],
            named: "Lightning",
            contract: .lightning(.channel(peer: "")),
            useSmallBalance: true
        )
        
        let keyrings = [
            KeyringDisplayInfo(named: "Private 1 of 7 multisig", actingAs: "Private individual"),
            KeyringDisplayInfo(named: "Corporate director", actingAs: "CEO of the company"),
            KeyringDisplayInfo(named: "Imported Electrum HD", actingAs: "Anonymous user"),
            KeyringDisplayInfo(named: "Legacy single key", actingAs: "Old miner :)")
        ]

        self.data = AppDisplayInfo(
            wallets: [savings, self.wallet, company, family, lightning],
            keyrings: keyrings,
            assets: [btc, btcn, shares, usdt, lnpbp]
        )
    }
}
