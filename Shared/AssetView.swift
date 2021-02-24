//
//  AssetView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI
import MyCitadelKit

struct AssetView: View {
    var asset: Asset

    private let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        List {
            Section(header: BalanceCard(assetId: asset.id)
                        .padding(.bottom, 30)
                        .aspectRatio(1.5, contentMode: .fill),
                    footer: Text("Information source: embedded genesis data")) {
                HStack(alignment: .center) {
                    SubheadingCell(title: "Asset Id", details: asset.id)
                    Spacer()
                    Button(action: {}) { Image(systemName: "doc.on.doc") }
                }
                DetailsCell(title: "Ticker", details: asset.ticker)
                DetailsCell(title: "Name", details: asset.name)
                DetailsCell(title: "Divisibility", details: "\(asset.decimalPrecision) subdecimals")
                DetailsCell(title: "Known since", details: dateFormatter.string(from: asset.genesisDate))
                
                if let ricardianContract = asset.ricardianContract {
                    NavigationLink(destination: Text(ricardianContract)) {
                        Text("Ricardian contract")
                            .font(.headline)
                    }
                } else {
                    DetailsCell(title: "Ricardian contract", details: "none")
                }
            }
            
            Section(header: Text("Balance information")) {
                DetailsCell(title: "Owned balance", details: asset.hasBalance ? asset.formattedBalance : "no asset yet")
                Button(action: {}) { Text("Buy").foregroundColor(.green) }
                if asset.hasBalance {
                    Button(action: {}) { Text("Sell").foregroundColor(.red) }
                }
            }

            Section(header: Text("Souveregnity status"), footer: Text("Information source: MyCitadel self-souvergnity digital assets raiting®")) {
                DetailsCell(title: "Category", details: asset.category.localizedDescription)
                DetailsCell(title: "Trust profile", details: asset.isNative ? "Trustless" : "Trusted issuer")
                DetailsCell(title: "Centralization", details: asset.isNative ? "Decentralized" : "Cenrtalized issue")
                DetailsCell(title: "Censorship resistance", details: "Uncensorable")
                DetailsCell(title: "Confiscatability", details: "Unconfiscable")
                DetailsCell(title: "Chain analysis", details: asset.isNative ? "Possible" : "Impossible")
                DetailsCell(title: "Ledger", details: asset.isNative ? "Public" : "Not used")
                DetailsCell(title: "Fungibility", details: asset.isNative ? "Moderate or high" : "High")
            }

            Section(header: Text("Technical profile"), footer: Text("Information source: embedded genesis data")) {
                DetailsCell(title: "Class", details: asset.isNative ? "Blockchain-based" : "Bearer rights")
                DetailsCell(title: "Blockchain", details: asset.network.localizedDescription)
                DetailsCell(title: "Asset class", details: asset.isNative ? "Native blockchain coin" : "Fungible asset (RGB-20)")
                SubheadingCell(title: "Digital asset technology", details: asset.isNative ? "Native blockchain unit of accounting" : "Client-side-validated smart contract")
            }
            
            Section(header: Text("Supply information"), footer: Text("Information source: embedded genesis data")) {
                Group {
                    DetailsCell(title: "Total issues", details: "\(asset.countIssues)")
                    DetailsCell(title: "First issue", details: dateFormatter.string(from: asset.genesisDate))
                    DetailsCell(title: "Last known issue", details: dateFormatter.string(from: asset.latestIssue))
                }
                DetailsCell(title: "Maximum possible supply", details: asset.formattedSupply(metric: .maxIssued))
                DetailsCell(title: "Known issued supply", details: asset.formattedSupply(metric: .knownIssued), subdetails: "83% of max. supply")
                DetailsCell(title: "Possible unknown issue", details: asset.formattedSupply(metric: .maxUnknown))
                DetailsCell(title: "Expected inflation", details: "\(asset.supply(metric: .maxIssued) ?? Double(UInt64.max) - (asset.supply(metric: .knownIssued) ?? 0)) \(asset.ticker)", subdetails: "\(100.0 - (asset.percentageIssued(includingUnknown: false) ?? 100.0))% of max. supply")
                DetailsCell(title: "Issue rights by", details: asset.isNative ? "mining" : "centralized issuer")
                DetailsCell(title: "Known burned supply", details: asset.formattedSupply(metric: .knownBurned), subdetails: "as of \(dateFormatter.string(from: CitadelVault.embedded.blockchainState.updatedAt))")
                DetailsCell(title: "Known replaced supply", details: asset.isReplacementPossible ? "none" : asset.formattedSupply(metric: .knownReplaced), subdetails: "as of \(dateFormatter.string(from: CitadelVault.embedded.blockchainState.updatedAt))")
            }

            Section(header: Text("Issuer information"), footer: Text("Information source: MyCitadel digital asset issuer database")) {
                SubheadingCell(title: "Issuer name", details: asset.authenticity.issuer?.name ?? "unknown")
                SubheadingCell(title: "Issuer details", details: asset.localizedIssuer)
                HStack(alignment: .center) {
                    SubheadingCell(title: "Verification status", details: asset.authenticity.status.localizedString)
                    Spacer()
                    AssetAuthenticityImage(asset: asset)
                        .font(.title3)
                }
                if let url = asset.authenticity.url {
                    Button(action: {}) {
                        HStack(alignment: .center) {
                            SubheadingCell(title: "Verification link", details: url)
                            Spacer()
                            Image(systemName: "chevron.right.2")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    HStack(alignment: .center) {
                        SubheadingCell(title: "Verification link", details: "none")
                    }
                }
            }

            Section(header: Text("Other ownable rights"), footer: Text("Information source: embedded genesis data")) {
                DetailsCell(title: "Renomination", details: asset.isRenominationPossible ? "possible" : "impossible")
                DetailsCell(title: "Proof of burn", details: asset.isProofOfBurnPossible ? "anybody" : "impossible")
                DetailsCell(title: "Replacement of lost assets", details: asset.isReplacementPossible ? "by the issuer" : "impossible")
            }

            if !asset.isNative {
                Section(footer: Text("Use QR code to share the asset genesis")) {
                    generateQRCode(from: asset.genesis)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            
            Label("More on information sources", systemImage: "info.circle")
        }
        .listStyle(GroupedListStyle())
            .navigationTitle("Digital asset profile")
    }
}

struct DetailsCell: View {
    @State var title: String
    @State var details: String
    @State var subdetails: String?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            VStack(alignment: .trailing) {
                Text(details)
                    .font(.body)
                    .multilineTextAlignment(.trailing)
                if let subdetails = subdetails {
                    Text(subdetails)
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct SubheadingCell: View {
    @State var title: String
    @State var details: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Spacer()
            Text(details)
                .font(.body)
        }.padding(.vertical, 6)
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AssetView(asset: CitadelVault.embedded.assets.values.first!)
        }
    }
}
