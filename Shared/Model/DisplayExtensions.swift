//
//  DisplayExtensions.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/23/21.
//

import SwiftUI
import MyCitadelKit

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
    
    public var verifiedSymbol: String {
        authenticity.status.verifiedSymbol
    }
    
    public var verifiedImage: some View {
        authenticity.status.verifiedImage
    }
    
    public var issuerLabel: some View {
        HStack(alignment: .center) {
            Text(authenticity.issuer?.name ?? "Unknown")
            verifiedImage.shadow(color: .white, radius: 3, x: 0, y: 0)
        }
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
        self.isVerified() ? "xmark.seal" : "checkmark.seal.fill"
    }
    
    public var verifiedImage: some View {
        let color: Color

        switch self {
        case .publicTruth: color = .blue
        case .verified: color = .green
        case .unverified: color = .orange
        }

        return Image(systemName: verifiedSymbol)
            .foregroundColor(color)
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
