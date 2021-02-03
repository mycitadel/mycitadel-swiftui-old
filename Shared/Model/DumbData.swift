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
        "Train ticket to Zug"
    ]

    public convenience init(randomWithAsset asset: AssetDisplayInfo) {
        let amount = Float.random(in: 0.95...166.6) / asset.fiatRate
        let direction = Bool.random() ? TransactionDirection.In : TransactionDirection.Out
        let note = Self.DUMB_NOTES.randomElement()!
        let date = Date(timeIntervalSinceNow: TimeInterval.random(in: 0...(60*60*24*30)))
        self.init(withAmount: amount, ofAsset: asset, directed: direction, note: note, date: date)
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
        let transactions = (0...Int.random(in: 20...40)).map { _ in
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
            withId: "BTC",
            ticker: "BTC",
            name: "Bitcoin (onchain)",
            symbol: "bitcoinsign.circle.fill",
            category: .bitcoin,
            btcRate: 1,
            fiatRate: 10_000
        )

        let shares = AssetDisplayInfo(
            withId: "PAN",
            ticker: "PAN",
            name: "Pandora Core",
            symbol: "arrowtriangle.down.circle.fill",
            category: .security,
            btcRate: 0.1,
            fiatRate: 1_000
        )

        let usdt = AssetDisplayInfo(
            withId: "USDT",
            ticker: "USDT",
            name: "US Dollar Tether",
            symbol: "dollarsign.circle.fill",
            category: .stablecoin,
            btcRate: 0.0001,
            fiatRate: 1.0
        )

        let btcn = AssetDisplayInfo(
            withId: "BTC*",
            ticker: "BTC*",
            name: "Bitcoin (RGB)",
            symbol: "bitcoinsign.circle.fill",
            category: .bitcoin,
            btcRate: 1,
            fiatRate: 10_000
        )

        let lnpbp = AssetDisplayInfo(
            withId: "LNP/BP",
            ticker: "LNP/BP",
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
        
        let lightning1 = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt],
            named: "MyCitadel",
            contract: .lightning(.channel(peer: "")),
            useSmallBalance: true
        )

        let lightning2 = AccountDisplayInfo(
            randomWithAssets: [btc, btcn, usdt],
            named: "Bitrefill",
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
            wallets: [savings, self.wallet, company, family, lightning1, lightning2],
            keyrings: keyrings,
            assets: [btc, btcn, shares, usdt, lnpbp]
        )
    }
}
