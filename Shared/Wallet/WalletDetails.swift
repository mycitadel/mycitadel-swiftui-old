//
//  ContractInfo.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI
import MyCitadelKit

struct WalletDetails: View {
    @State var wallet: WalletContract
    
    var body: some View {
        Form {
            Section(header: Text("Contract name")) {
                TextField("Name the contract", text: $wallet.name)
                    .font(.title)
            }
            
            Section(header: Text("General info")) {
                SubheadingCell(title: "Contract id", details: wallet.id)
                DetailsCell(title: "Contract type", details: wallet.policy.contractType.localizedName)
                DetailsCell(title: "Address format", details: wallet.descriptorInfo.addrType ?? "none")
                if wallet.descriptorInfo.isNestable {
                    DetailsCell(title: "Alternative format", details: "\(wallet.descriptorInfo.addrType!)-in-P2SH")
                }
                DetailsCell(title: "Total addresses", details: "\(wallet.descriptorInfo.keyspaceSize)")
                DetailsCell(title: "Network", details: wallet.chain.localizedDescription)
                DetailsCell(title: "RGB compatible", details: wallet.descriptorInfo.isRGBEnabled ? "yes" : "no")
            }
            
            Section(header: Text("Descriptor")) {
                DetailsCell(title: "Type", details: wallet.descriptorInfo.fullType)
                DetailsCell(title: "Category", details: wallet.descriptorInfo.contentType)
                DetailsCell(title: "Can be P2SH wrapped", details: wallet.descriptorInfo.isNestable ? "yes" : "no")
                if let checksum = wallet.descriptorInfo.checksum {
                    DetailsCell(title: "Checksum", details: checksum)
                }
                SubheadingCell(title: "Full descriptor", details: wallet.descriptorInfo.descriptor)
            }

            Section(header: Text("Spending policy")) {
                SubheadingCell(title: "Spending policy", details: wallet.descriptorInfo.policy)
                if let sigsRequired = wallet.descriptorInfo.sigsRequired {
                    DetailsCell(title: "Required signatures", details: "\(sigsRequired)")
                }
                DetailsCell(title: "Total keys", details: "\(wallet.descriptorInfo.keys.count)")
                DetailsCell(title: "Keys sorted", details: wallet.descriptorInfo.isSorted ? "yes" : "no")
            }
            
            ForEach(wallet.descriptorInfo.keys, id: \.branch.identifier) { keyInfo in
                Section(header: Text("Signing key \(keyInfo.branch.fingerprint)")) {
                    SubheadingCell(title: "Full key", details: keyInfo.fullKey)
                    SubheadingCell(title: "Is seed based", details: keyInfo.seedBased ? "yes" : "no")
                    SubheadingCell(title: "BIP32 derivation", details: keyInfo.bip32Derivation)
                    if let master = keyInfo.master {
                        if let xpubkey = master.xpubkey {
                            SubheadingCell(title: "Master key", details: xpubkey)
                        }
                        if let identifier = master.identifier {
                            DetailsCell(title: "Master key identifier", details: identifier)
                        }
                        DetailsCell(title: "Master key fingerprint", details: master.fingerprint)
                    }
                    if let identity = keyInfo.identityKey {
                        if let xpubkey = identity.xpubkey {
                            SubheadingCell(title: "Identity key", details: xpubkey)
                        }
                        if let identifier = identity.identifier {
                            DetailsCell(title: "Identity key identifier", details: identifier)
                        }
                        DetailsCell(title: "Identity key fingerprint", details: identity.fingerprint)
                    }
                    SubheadingCell(title: "Account key", details: keyInfo.branch.xpubkey)
                    SubheadingCell(title: "Account key identifier", details: keyInfo.branch.identifier)
                    DetailsCell(title: "Account key fingerprint", details: keyInfo.branch.fingerprint)
                }
            }
            
            Section(header: Text("Share descriptor")) {
                generateQRCode(from: wallet.descriptorInfo.descriptor)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .navigationTitle("Contract details")
    }
}

struct ContractInfo_Previews: PreviewProvider {
    static var previews: some View {
        WalletDetails(wallet: CitadelVault.embedded.contracts.first!)
    }
}
