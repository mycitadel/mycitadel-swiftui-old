//
//  BalancePager.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

// TODO: Move this to MyCitadelKit

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

public enum ContractType: Int, Identifiable {
    case current = 1
    case saving = 2
    case instant = 3
    case storm = 4
    case prometheus = 5
    case trading = 6
    case staking = 7
    case liquidity = 8

    public var id: ContractType {
        self
    }

    public var imageName: String {
        switch self {
        case .current: return "banknote"
        case .saving: return "building.columns.fill"
        case .instant: return "bolt.fill"
        case .storm: return "cloud.bolt.rain.fill"
        case .prometheus: return "cpu"
        case .trading: return "arrow.left.arrow.right.circle.fill"
        case .staking: return "square.stack.3d.up.fill"
        case .liquidity: return "drop.fill"
        }
    }
    
    public var title: String {
        switch self {
        case .current: return "Current account"
        case .saving: return "Saving account"
        case .instant: return "Instant payments (Lightning)"
        case .storm: return "Data storage"
        case .prometheus: return "Computing"
        case .trading: return "Trading"
        case .staking: return "Staking"
        case .liquidity: return "Liquidity provider / DEX"
        }
    }

    public var description: String {
        switch self {
        case .current: return "This is a “normal” bitcoin or digital assets wallet account, suitable for on-chain payments. Accounts of this type may be a single-signature (personal) or multi-signatures (for corporate/family use). Also, power users or enterprise customers will be able to write custom lock times and other conditions with miniscript. However, if you are looking for HODLing we advise you to look at the next type of accounts: saving account; since current accounts are mostly used for paying activities and their private keys are usually kept in the hot state."
        case .saving: return "This is for true HODlers! Saving accounts always keep private keys cold + in the future will support conventants, once CLV will happen!"
        case .instant: return "Fast & cheap micropayments with lightning channels of different sorts: unilaterally funded channels, bilateraly funded channels, channel factories, RGB-asset enabled channels – we have all of them"
        case .storm: return "Data storage"
        case .prometheus: return "Computing"
        case .trading: return "Use decentralized exchange functionality of the lightning network to do cheap & efficient trading operations"
        case .staking: return "Put your bitcoins & digital assets into a liquidity pool at the lightning node and earn your part of the fees from the node operating as a part of the decentralized exchange"
        case .liquidity: return "Operate your lightning node as a part of the decentralized exchange by providing your node liquidity to the network – and maintain a liquidity pool to earn more fees"
        }
    }
    
    public var enabled: Bool {
        switch self {
        case .current: return true
        default: return false
        }
    }
    
    public var primaryColor: Color {
        switch self {
        case .current: return Color.orange
        case .saving: return Color.green
        case .instant: return Color.red
        default: return Color.blue
        }
    }
    
    public var secondaryColor: Color {
        switch self {
        case .current: return Color.yellow
        case .saving: return Color(.sRGB, red: 0.333, green: 1, blue: 0.333, opacity: 1)
        case .instant: return Color.purple
        default: return Color(.sRGB, red: 0.333, green: 0.333, blue: 1, opacity: 1)
        }
    }
    
    public var gradient: Gradient {
        Gradient(colors: [self.primaryColor, self.secondaryColor])
    }
}

public enum AccountContract {
    case current(CurrentContract)
    case saving(SavingContract)
    case lightning(LightningContract)
    case storm(StormContract)
    case prometheus(PrometheusContract)
    case trading(TradingContract)

    public var contractType: ContractType {
        switch self {
        case .current(_): return .current
        case .saving(_): return .saving
        case .lightning(_): return .instant
        case .storm(_): return .storm
        case .prometheus(_): return .prometheus
        case .trading(_): return .trading
        }
    }
    
    public var imageName: String {
        self.contractType.imageName
    }
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

public class AccountDisplayInfo: ObservableObject, Identifiable {
    public let id: UUID = UUID()
    public let contract: AccountContract
    @Published var name: String
    @Published var assets: [AssetDisplayInfo]
    @Published var transactions: [TransactionDisplayInfo]
    
    public var imageName: String {
        self.contract.imageName
    }
    
    public init(named name: String, havingAssets assets: [AssetDisplayInfo] = [],
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
    public let id: String
    public let genesis: String
    public let ticker: String
    public let name: String
    public let details: String? = nil
    public let precision: UInt8

    // These are not parts of the genesis and purely UI related
    public var symbol: String
    public var category: AssetCategory // Derived from schema id
    public var issuer: String
    public var verified: Bool
    
    @Published public var btcRate: Float
    @Published public var fiatRate: Float
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

    public var gradient: Gradient {
        Gradient(colors: [self.category.primaryColor(), self.category.secondaryColor()])
    }
    
    public var verifiedSymbol: String {
        verified ? "checkmark.seal.fill" : "xmark.seal"
    }
    
    public var verifiedImage: some View {
        Image(systemName: verifiedSymbol)
            .foregroundColor(verified ? .green : .orange)
    }
    
    public var issuerLabel: some View {
        HStack(alignment: .center) {
            Text(issuer)
            verifiedImage.shadow(color: .white, radius: 3, x: 0, y: 0)
        }
    }

    public init(withId id: String, genesis: String, ticker: String, name: String, symbol: String, category: AssetCategory = .security,
                issuer: String = "unknown issuer", verified: Bool = false,
                precision: UInt8 = 8, btcRate: Float = 1.0 / 10_000, fiatRate: Float = 1, balance: UInt64 = 0) {
        self.id = id
        self.genesis = genesis
        self.ticker = ticker
        self.name = name
        self.symbol = symbol
        self.category = category
        self.issuer = issuer
        self.verified = verified
        self.precision = precision
        self.btcRate = btcRate
        self.fiatRate = fiatRate
        self.atomicBalance = 0
    }
    
    public convenience init(withAsset asset: RGB20Asset) {
        self.init(withId: asset.id, genesis: asset.genesis, ticker: asset.ticker, name: asset.name, symbol: "coloncurrencysign.circle.fill", precision: asset.fractionalBits)
    }
    
    public convenience init(withAsset asset: AssetDisplayInfo, balance: Float = 0) {
        self.init(
            withId: asset.id, genesis: asset.genesis, ticker: asset.ticker, name: asset.name, symbol: asset.symbol, category: asset.category,
            issuer: asset.issuer, verified: asset.verified,
            precision: asset.precision, btcRate: asset.btcRate, fiatRate: asset.fiatRate
        )
        atomicBalance = asset.transmutate(accounting: balance)
    }

    public func transmutate(atomic: UInt64) -> Float {
        Float(atomic) / pow(Float(10), Float(precision))
    }

    public func transmutate(accounting: Float) -> UInt64 {
        UInt64(accounting * pow(Float(10), Float(precision)))
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
