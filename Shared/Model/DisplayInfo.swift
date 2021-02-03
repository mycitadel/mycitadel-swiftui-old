//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

public class AppDisplayInfo: ObservableObject {
    @Published public var wallets: [AccountDisplayInfo]
    @Published public var keyrings: [KeyringDisplayInfo]
    @Published public var assets: [AssetDisplayInfo]

    public init(wallets: [AccountDisplayInfo], keyrings: [KeyringDisplayInfo], assets: [AssetDisplayInfo]) {
        self.wallets = wallets
        self.keyrings = keyrings
        self.assets = assets
    }
}

public class KeyringDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    @Published public var name: String
    @Published public var actingAs: String
    @Published public var details: String?
    public var fingerprint: String = ""
    public var identifier: String = ""
    public var derivationPath: String = "m"
    
    public init(named name: String, actingAs: String) {
        self.name = name
        self.actingAs = actingAs
    }
}

public enum AccountContract {
    case current(CurrentContract)
    case saving(SavingContract)
    case lightning(LightningContract)
    case storm(StormContract)
    case prometheus(PrometheusContract)
    case trading(TradingContract)
    case rgb(RgbContract)
}

public enum SpendingDescriptors {
    case bare
    case legacy
    case legacySegWit
    case segWit
    case taproot
}

public enum SpendigLock: Hashable {
    case pubkey(id: String)
    case multisig(threshold: UInt8, ids: [String])
    case miniscript(script: String)
    case musig
    case tapscript(script: String)
}

public enum WalletScripting: Hashable {
    case publicKey
    case multisig
    case miniscript
}

public struct CurrentContract {
    public let lock: SpendigLock
    public let descriptors: [SpendingDescriptors]
    
    public init(lock: SpendigLock = .pubkey(id: ""), descriptors: [SpendingDescriptors] = [.segWit]) {
        self.lock = lock
        self.descriptors = descriptors
    }
}

public enum SavingContract {
    case multisig(threshold: UInt8)
    case miniscript(script: String)
    case musig
    case tapscript(script: String)
    case covenant
}

public enum LightningContract {
    case channel(peer: String)
    case factory(peers: [String])
}

public struct StormContract {
    public let peer: String
}

public enum PrometheusContract {
    case worker
    case verifier
    case arbiter
}

public enum TradingContract {
    case dlcFuture
    case lightningDEX
    case liquidityProvider
    case lightspeed
}

public enum RgbContract {
    case loan
}

public class AccountDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    public let contract: AccountContract
    @Published var name: String
    @Published var assets: [BalanceDisplayInfo]
    @Published var transactions: [TransactionDisplayInfo]
    
    public var imageName: String {
        switch contract {
        case .current(_): return "banknote"
        case .saving(_): return "building.columns.fill"
        case .lightning(_): return "bolt.fill"
        case .storm(_): return "cloud.bolt.rain.fill"
        case .prometheus(_): return "cpu"
        case .trading(_): return "arrow.left.arrow.right.circle.fill"
        case .rgb(_): return "sparkles"
        }
    }
    
    public init(named name: String, havingAssets assets: [BalanceDisplayInfo] = [],
                transactions: [TransactionDisplayInfo] = [], contract: AccountContract = .current(CurrentContract())) {
        self.name = name
        self.contract = contract
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
    // These are parts of the genesis
    public let ticker: String
    public let name: String
    public let details: String? = nil
    public let precision: UInt8
    public let category: AssetCategory // Derived from schema id

    // These are not parts of the genesis and purely UI related
    public let symbol: String
    @Published public var btcRate: Float
    @Published public var fiatRate: Float

    public var gradient: Gradient {
        Gradient(colors: [self.category.primaryColor(), self.category.secondaryColor()])
    }
    
    public convenience init(withAsset asset: RGB20Asset) {
        self.init(withTicker: asset.ticker, name: asset.name, symbol: "coloncurrencysign.circle.fill", precision: asset.fractionalBits)
    }

    public init(withTicker ticker: String, name: String, symbol: String, category: AssetCategory = .security,
                precision: UInt8 = 8, btcRate: Float = 1.0 / 10_000, fiatRate: Float = 1) {
        self.ticker = ticker
        self.name = name
        self.symbol = symbol
        self.category = category
        self.precision = precision
        self.btcRate = btcRate
        self.fiatRate = fiatRate
    }
    
    public func transmutate(atomic: UInt64) -> Float {
        Float(atomic) / pow(Float(10), Float(precision))
    }

    public func transmutate(accounting: Float) -> UInt64 {
        UInt64(accounting * pow(Float(10), Float(precision)))
    }
}

public class BalanceDisplayInfo: AssetDisplayInfo {
    @Published public var atomicBalance: UInt64

    public var balance: Float {
        get {
            Float(atomicBalance) / pow(Float(10), Float(precision))
        }
        set {
            atomicBalance = UInt64(newValue * pow(Float(10), Float(precision)))
        }
    }
    
    public var btcBalance: Float {
        self.balance * self.btcRate
    }
    
    public var fiatBalance: Float {
        self.balance * self.fiatRate
    }
        
    public init(withAsset asset: AssetDisplayInfo, balance: Float = 0) {
        atomicBalance = asset.transmutate(accounting: balance)
        super.init(
            withTicker: asset.ticker, name: asset.name, symbol: asset.symbol, category: asset.category,
            precision: asset.precision, btcRate: asset.btcRate, fiatRate: asset.fiatRate
        )
    }
}

public enum TransactionDirection {
    case In
    case Out
}

public class TransactionDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    public let direction: TransactionDirection
    public let asset: AssetDisplayInfo

    public var date: Date
    public var atomicAmount: UInt64
    @Published public var contact: ContactDisplayInfo?
    @Published public var comment: String

    public var amount: Float {
        get {
            asset.transmutate(atomic: atomicAmount)
        }
        set {
            atomicAmount = asset.transmutate(accounting: newValue)
        }
    }
    
    public init(withAmount amount: Float, ofAsset asset: AssetDisplayInfo, directed direction: TransactionDirection,
                note comment: String, contactOrMerchant contact: ContactDisplayInfo? = nil, date: Date = Date()) {
        self.asset = asset
        self.direction = direction
        self.atomicAmount = asset.transmutate(accounting: amount)
        self.comment = comment
        self.contact = contact
        self.date = date
    }
}

public class ContactDisplayInfo: ObservableObject, Identifiable {
    @Published public var name: String
    @Published public var notes: String? = nil
    @Published public var avatar: Image?
    @Published public var nodes: [String] = []
    @Published public var bitcoinKeys: [String] = []
    @Published public var identityKeys: [String] = []
    
    public init(named name: String, withAvatar avatar: Image? = nil) {
        self.name = name
        self.avatar = avatar
    }
}
