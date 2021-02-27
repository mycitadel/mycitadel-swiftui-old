//
//  DisplayExtensions.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/23/21.
//

import SwiftUI
import MyCitadelKit

extension BitcoinNetwork {
    var localizedDescription: String {
        switch self {
        case .mainnet: return "Bitcoin mainnet"
        case .testnet: return "Bitcoin testnet"
        case .signet: return "Bitcoin signet"
        }
    }
    
    var localizedSats: String {
        switch self {
        case .mainnet: return "Sats."
        default: return "tSats."
        }
    }

    var localizedSatoshis: String {
        switch self {
        case .mainnet: return "Satoshis"
        default: return "Testnet satoshis"
        }
    }
}

extension AssetCategory {
    var localizedDescription: String {
        switch self {
        case .currency:
            return "Ditial currency"
        case .stablecoin:
            return "Stable coin"
        case .token:
            return "Fungible asset"
        case .nft:
            return "Non-fungible token"
        }
    }

    func primaryColor() -> Color {
        switch self {
        case .currency: return Color.orange
        case .stablecoin: return Color.green
        case .token: return Color.red
        case .nft: return Color.blue
        }
    }
    
    func secondaryColor() -> Color {
        switch self {
        case .currency: return Color.yellow
        case .stablecoin: return Color(.sRGB, red: 0.333, green: 1, blue: 0.333, opacity: 1)
        case .token: return Color.purple
        case .nft: return Color(.sRGB, red: 0.333, green: 0.333, blue: 1, opacity: 1)
        }
    }
}

extension Asset {
    public var gradient: Gradient {
        Gradient(colors: [self.category.primaryColor(), self.category.secondaryColor()])
    }

    public var symbol: String {
        switch category {
        case .currency: return "bitcoinsign.circle.fill"
        case .stablecoin: return "dollarsign.circle.fill"
        case .token: return "arrowtriangle.down.circle.fill"
        case .nft: return "arrowtriangle.down"
        }
    }
    
    public var formattedBalance: String {
        "\(balance.total) \(ticker)"
    }
    
    public func formattedSupply(metric: SupplyMetric) -> String {
        "\(supply(metric: metric) ?? 0) \(ticker)"
    }

    public var localizedIssuer: String {
        isNative ? "Decentralized consensus on \(network.localizedDescription) blockchain" : "Trusted centralized party"
    }
}

extension AssetAuthenticity {
    public var symbol: String {
        status.verifiedSymbol
    }
    
    public var color: Color {
        status.verifiedColor
    }
}

extension VerificationStatus {
    public var localizedString: String {
        switch self {
        case .publicTruth: return "Public fact"
        case .verified: return "Verified"
        case .unverified: return "Unverified"
        }
    }
    
    public var verifiedSymbol: String {
        self.isVerified() ? "checkmark.seal.fill" : "xmark.seal"
    }
    
    public var verifiedColor: Color {
        switch self {
        case .publicTruth: return .blue
        case .verified: return .green
        case .unverified: return .orange
        }
    }
}

extension WalletContract {
    var transactions: [TransactionDisplayInfo] {
        []
    }
    
    public var imageName: String {
        self.policy.contractType.imageName
    }
    
}

extension Policy {
    public var contractType: ContractType {
        switch self {
        case .current(_): return .current
        }
    }
}

extension Balance {
    public var fiatBalance: Double {
        0
    }
    public var btcBalance: Double {
        0
    }
}
