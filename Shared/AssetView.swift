//
//  AssetView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI
import MyCitadelKit

struct AssetView: View {
    let asset: AssetDisplayInfo

    var body: some View {
        List {
            Section(header: AssetCard(asset: asset)
                        .padding(.bottom, 30)
                        .aspectRatio(1.5, contentMode: .fill),
                    footer: Text("Information source: embedded genesis data")) {
                HStack(alignment: .center) {
                    SubheadingCell(title: "Isset Id", details: asset.id)
                    Spacer()
                    Button(action: {}) { Image(systemName: "doc.on.doc") }
                }
                DetailsCell(title: "Ticker", details: asset.ticker)
                DetailsCell(title: "Name", details: asset.name)
                DetailsCell(title: "Divisibility", details: "\(asset.precision) subdecimals")
                DetailsCell(title: "Known since", details: "09 Jan 2009")
                NavigationLink(destination: Text("none")) {
                    Text("Recardian contract")
                        .font(.headline)
                }
            }
            
            Section(header: Text("Balance information"), footer: Text("You do not own the asset")) {
                Button(action: {}) { Text("Buy some") }
            }

            Section(header: Text("Souveregnity status"), footer: Text("Information source: MyCitadel self-souvergnity digital assets raiting®")) {
                DetailsCell(title: "Category", details: "Digital currency")
                DetailsCell(title: "Trust profile", details: "Trustless")
                DetailsCell(title: "Centralization", details: "Decentralized")
                DetailsCell(title: "Censorship resistance", details: "Uncensorable")
                DetailsCell(title: "Confiscatability", details: "Unconfiscable")
                DetailsCell(title: "Chain analysis", details: "Possible")
                DetailsCell(title: "Ledger", details: "Public")
                DetailsCell(title: "Fungibility", details: "Can be tainted")
            }

            Section(header: Text("Technical profile"), footer: Text("Information source: embedded genesis data")) {
                DetailsCell(title: "Class", details: "Blockchain-based")
                DetailsCell(title: "Blockchain", details: "Bitcoin mainnet")
                DetailsCell(title: "Asset class", details: "Fungible asset (RGB-20)")
                SubheadingCell(title: "Digital asset technology", details: "Native blockchain unit of accounting")
            }
            
            Section(header: Text("Supply information"), footer: Text("Information source: embedded genesis data")) {
                Group {
                    DetailsCell(title: "Total issues", details: "666 999")
                    DetailsCell(title: "First issue", details: "09 Jan 2010")
                    DetailsCell(title: "Last known issue", details: "03 Feb 2021")
                }
                DetailsCell(title: "Maximum possible supply", details: "21 000 000 BTC")
                DetailsCell(title: "Known issued supply", details: "16 000 000 BTC", subdetails: "83% of max. supply")
                DetailsCell(title: "Possible unknown issue", details: "6.25 BTC")
                DetailsCell(title: "Expected inflation", details: "5 000 000 BTC", subdetails: "17% of max. supply")
                DetailsCell(title: "Issue rights by", details: "PoW mining")
                DetailsCell(title: "Issue right holders", details: "unenumerable")
                DetailsCell(title: "Known burned supply", details: "≤800 000 BTC", subdetails: "as of 03 Feb 2021")
                DetailsCell(title: "Known circulating supply", details: "≥15 200 000 BTC", subdetails: "as of 03 Feb 2021")
            }

            Section(header: Text("Issuer information"), footer: Text("Information source: MyCitadel digital asset issuer database")) {
                SubheadingCell(title: "Issuer name", details: asset.issuer)
                SubheadingCell(title: "Issuer details", details: "Decentralized consensus in bitcoin mainnet blockchain")
                HStack(alignment: .center) {
                    SubheadingCell(title: "Verification status", details: "Publically known")
                    Spacer()
                    asset.verifiedImage
                        .font(.title3)
                }
                Button(action: {}) {
                    HStack(alignment: .center) {
                        SubheadingCell(title: "Verification link", details: "https://bitcoin.org")
                        Spacer()
                        Image(systemName: "chevron.right.2")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }

            Section(header: Text("Other ownable rights"), footer: Text("Information source: embedded genesis data")) {
                DetailsCell(title: "Renomination", details: "impossible")
                DetailsCell(title: "Proof of burn", details: "anybody")
                DetailsCell(title: "Replacement of lost assets", details: "impossible")
            }
            
            Section(footer: Text("Use QR code to share the asset genesis")) {
                generateQRCode(from: asset.genesis)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(1, contentMode: .fit)
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
            AssetView(asset: DumbData.init().data.assets[0])
        }
    }
}
