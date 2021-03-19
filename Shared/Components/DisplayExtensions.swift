//
//  DisplayExtensions.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/23/21.
//

import SwiftUI
import CitadelKit

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
    
    public var fiatExchangeRate: Double {
        return 0
    }
    
    public var bitcoinExchangeRate: Double {
        return 0
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
    public var imageName: String {
        self.policy.contractType.imageName
    }
    
    public var contractType: ContractType {
        self.policy.contractType
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
    
    public var localizedName: String {
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

    public var localizedDescription: String {
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

extension UniversalParser.ParsedData {
    public var localizedDescription: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .url:
            return "URL"
        case .address(_):
            return "Bitcoin address"
        case .bolt11Invoice:
            return "LN BOLT11 invoice"
        case .lnpbpId:
            return "LNPBP-14 id"
        case .lnpbpData:
            return "LNPBP-14 data"
        case .lnpbpZData:
            return "LNPBP-14 data (compressed)"
        case .lnbpInvoice(_):
            return "LNPBP-38 invoice"
        case .rgbSchemaId:
            return "RGB Schema Id"
        case .rgbContractId:
            return "RGB Contract Id"
        case .rgbSchema:
            return "RGB Schema"
        case .rgbGenesis:
            return "RGB Genesis"
        case .rgbConsignment:
            return "RGB Consignment"
        case .rgb20Asset(_):
            return "RGB20 Asset"
        case .wifPrivateKey:
            return "WIP private key"
        case .xpub:
            return "Extended public key"
        case .xpriv:
            return "Extended private key"
        case .derivation:
            return "BIP32 derivation path"
        case .descriptor:
            return "Script pubkey descriptor"
        case .miniscript:
            return "Miniscript"
        case .script:
            return "Bitcoin script"
        case .outpoint(_):
            return "Transaction outpoint"
        case .hash160(_):
            return "160-bit hash"
        case .genesis(_):
            return "Genesis block hash"
        case .hex256(_):
            return "256-bit number, private key, hash"
        case .transaction:
            return "Transaction data"
        case .psbt:
            return "Partially signed transaction"
        case .bech32Unknown(hrp: let hrp, payload: _, data: _):
            return "Bech32-encoded \(hrp) data"
        case .base64Unknown(_):
            return "Unknown Base64-encoded data"
        case .base58Unknown(_):
            return "Unknown Base58-encoded data"
        case .hexUnknown(_):
            return "Hexadecimal data"
        }
    }
}

extension AddressNetwork {
    var localizedName: String {
        switch self {
        case .mainnet: return "Mainnet"
        case .testnet: return "Testnet"
        case .regtest: return "Regtest"
        }
    }
}

extension AddressFormat {
    var localizedPayload: String {
        switch self {
        case .P2PKH: return "Public key hash"
        case .P2SH: return "Script hash"
        case .P2WPKH: return "Public key hash"
        case .P2WSH: return "Script hash"
        case .P2TR: return "BIP-340 public key"
        case .future(_): return "Witness programm"
        }
    }
}

extension WitnessVersion {
    var localizedDescription: String {
        switch self {
        case .none: return "pre-SegWit"
        case .segwit: return "SegWit v0"
        case .taproot: return "Taproot"
        case .future(_): return "Future SegWit"
        }
    }
}

extension ValidationStatus {
    var localizedName: String {
        switch self.validity {
        case .valid: return "Success"
        case .unresolvedTransactions: return "Danger"
        case .invalid: return "Failure"
        }
    }
    var systemImage: String {
        switch self.validity {
        case .valid: return "checkmark.shield.fill"
        case .unresolvedTransactions: return "exclamationmark.triangle.fill"
        case .invalid: return "xmark.octagon.fill"
        }
    }
    var color: Color {
        switch self.validity {
        case .valid: return .green
        case .unresolvedTransactions: return .yellow
        case .invalid: return .red
        }
    }
}
