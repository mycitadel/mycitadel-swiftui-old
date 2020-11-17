//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

public class AppDisplayInfo: ObservableObject {
    @Published public var wallets: [WalletDisplayInfo]
    @Published public var keyrings: [KeyringDisplayInfo]
    @Published public var assets: [AssetDisplayInfo]

    public init(wallets: [WalletDisplayInfo], keyrings: [KeyringDisplayInfo], assets: [AssetDisplayInfo]) {
        self.wallets = wallets
        self.keyrings = keyrings
        self.assets = assets
    }
}

public class KeyringDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    @Published public var name: String
    @Published public var details: String?
    public var fingerprint: String = ""
    public var identifier: String = ""
    public var derivationPath: String = "m"
    
    public init(named name: String) {
        self.name = name
    }
}

public class WalletDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    @Published var name: String
    @Published var assets: [BalanceDisplayInfo]
    @Published var transactions: [TransactionDisplayInfo]
    
    public init(named name: String, havingAssets assets: [BalanceDisplayInfo], transactions: [TransactionDisplayInfo]) {
        self.name = name
        self.assets = assets
        self.transactions = transactions
    }
}

public enum AssetCategory {
    case bitcoin
    case stablecoin
    case security
    case collectible
    
    func primaryColor() -> Color {
        switch self {
        case .bitcoin: return Color.orange
        case .stablecoin: return Color.green
        case .security: return Color.red
        case .collectible: return Color.blue
        }
    }
    
    func secondaryColor() -> Color {
        switch self {
        case .bitcoin: return Color.yellow
        case .stablecoin: return Color(.sRGB, red: 0.333, green: 1, blue: 0.333, opacity: 1)
        case .security: return Color.purple
        case .collectible: return Color(.sRGB, red: 0.333, green: 0.333, blue: 1, opacity: 1)
        }
    }
}

public class AssetDisplayInfo: ObservableObject, Identifiable {
    public let ticker: String
    public let name: String
    public let symbol: String
    public let category: AssetCategory

    public var gradient: Gradient {
        Gradient(colors: [self.category.primaryColor(), self.category.secondaryColor()])
    }
    
    public init(withTicker ticker: String, name: String, symbol: String, category: AssetCategory = .security) {
        self.ticker = ticker
        self.name = name
        self.symbol = symbol
        self.category = category
    }
}

public class BalanceDisplayInfo: ObservableObject {
    public let ticker: String
    public let name: String
    public let symbol: String
    public let category: AssetCategory
    @Published public var balance: Float
    @Published public var btcRate: Float
    @Published public var fiatRate: Float

    public var btcBalance: Float {
        self.balance * self.btcRate
    }
    
    public var fiatBalance: Float {
        self.balance * self.fiatRate
    }
    
    public var gradient: Gradient {
        Gradient(colors: [self.category.primaryColor(), self.category.secondaryColor()])
    }
    
    public init(withAsset asset: AssetDisplayInfo, balance: Float = 0, btcRate: Float = 1.0 / 10_000, fiatRate: Float = 1, category: AssetCategory = .security) {
        self.ticker = asset.ticker
        self.name = asset.name
        self.symbol = asset.symbol
        self.category = asset.category
        self.balance = balance
        self.btcRate = btcRate
        self.fiatRate = fiatRate
    }
    
    public init(withTicker ticker: String, name: String, symbol: String, balance: Float = 0, btcRate: Float = 1.0 / 10_000, fiatRate: Float = 1, category: AssetCategory = .security) {
        self.ticker = ticker
        self.name = name
        self.symbol = symbol
        self.category = category
        self.balance = balance
        self.btcRate = btcRate
        self.fiatRate = fiatRate
    }
}

public enum TransactionDirection {
    case In
    case Out
}

public class TransactionDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    public let direction: TransactionDirection
    public let date: Date = Date()
    public let amount: UInt64
    @Published public var comment: String
    
    public init(withAmount amount: UInt64, directed direction: TransactionDirection, note comment: String) {
        self.direction = direction
        self.amount = amount
        self.comment = comment
    }
}

public enum WalletScripting: Hashable {
    case publicKey
    case multisig
    case miniscript
}
