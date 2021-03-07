//
//  UtxoView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/5/21.
//

import SwiftUI
import MyCitadelKit

struct UtxoView: View {
    @Environment(\.currencyUoA) var fiatUoA: String

    let wallet: WalletContract

    @State var outpoint: OutPoint
    @State var addressDerivation: AddressDerivation

    private var address: String {
        addressDerivation.address
    }
    private var derivation: String {
        addressDerivation.path
    }
    private var assetBalances: [(RGB20Asset, Double)] {
        wallet.addressAllocations(address).assetBalances(forOutpoint: outpoint).filter { $0.value != 0 }
            .compactMap { assetId, amount in
            guard let asset = CitadelVault.embedded.assets[assetId] as? RGB20Asset else { return nil }
            if amount == 0 {
                return nil
            }
            return (asset, amount)
        }
    }
    private var network: BitcoinNetwork {
        CitadelVault.embedded.network
    }
    private var nativeAsset: NativeAsset {
        CitadelVault.embedded.nativeAsset
    }
    private var bitcoins: Double {
        wallet.addressAllocations(address).bitcoinBalance(forOutpoint: outpoint, network: network)
    }
    private var satoshis: UInt64 {
        wallet.addressAllocations(address).satoshisBalance(forOutpoint: outpoint, network: network)
    }
    private var currencyEquivalent: Double {
        bitcoins * nativeAsset.fiatExchangeRate
    }
    
    #if os(macOS)
    private let listStyle = SidebarListStyle()
    #else
    private let listStyle = GroupedListStyle()
    #endif
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .primaryAction
        #endif
    }

    var body: some View {
        List {
            Section {
                DetailsCell(title: "Wallet", details: wallet.name)
                SubheadingCell(title: "Address", details: address, clipboardCopy: true)
                DetailsCell(title: "Derivation index", details: derivation)
            }

            Section {
                SubheadingCell(title: "Transaction Id", details: outpoint.txid, clipboardCopy: true)
                DetailsCell(title: "Output number", details: "\(outpoint.vout)")
            }
            
            Section(header: Text("Bitcoins")) {
                Button(action: { clipboardCopy(text: "\(bitcoins)") }) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(network.coinName())
                        Spacer()
                        Text("\(bitcoins)")
                            .font(.headline)
                        Text(network.ticker())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "doc.on.doc")
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: { clipboardCopy(text: "\(satoshis)") }) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(network.localizedSatoshis)
                        Spacer()
                        Text("\(satoshis)")
                            .font(.headline)
                        Text(network.localizedSats)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "doc.on.doc")
                    }
                }
                .foregroundColor(.primary)

                Button(action: { clipboardCopy(text: "\(currencyEquivalent)") }) {
                    HStack(alignment: .lastTextBaseline) {
                        Text("Currency equivalent")
                        Spacer()
                        Text("\(currencyEquivalent)")
                            .font(.headline)
                        Text(fiatUoA)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "doc.on.doc")
                    }
                }
                .foregroundColor(.primary)
            }
            
            Section(header: Text("RGB20 assets"), footer: assetsFooter) {
                ForEach(assetBalances, id: \.0) { (asset, amount) in
                    HStack(alignment: .lastTextBaseline) {
                        Text(asset.name)
                        Spacer()
                        Text("\(amount)")
                        Text(asset.ticker)
                    }
                }
            }
        }
        .listStyle(listStyle)
        .navigationTitle("UTXO details")
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                Button(action: movePrev) {
                    Image(systemName: "chevron.backward")
                }.disabled(prev == nil)
                Button(action: moveNext) {
                    Image(systemName: "chevron.forward")
                }.disabled(next == nil)
            }
        }
    }
    
    var assetsFooter: some View {
        if assetBalances.count == 0 {
            return Text("No assets")
        } else {
            return Text("")
        }
    }

    private var addressUtxos: [OutPoint] {
        Array(wallet.addressAllocations(address).outpointBalances.keys)
    }
    private var index: Int? {
        addressUtxos.firstIndex { $0 == outpoint }
    }
    private var prev: OutPoint? {
        guard let index = index else { return nil }
        if index <= 0 {
            return nil
        }
        return addressUtxos[index - 1]
    }
    private var next: OutPoint? {
        guard let index = index else { return nil }
        if index + 1 >= addressUtxos.count {
            return nil
        }
        return addressUtxos[index + 1]
    }
    
    func movePrev() {
        if let prev = prev {
            outpoint = prev
        }
    }
    func moveNext() {
        if let next = next {
            outpoint = next
        }
    }
}

/*
struct UtxoView_Previews: PreviewProvider {
    static let wallet = CitadelVault.embedded.contracts.first!
    static var previews: some View {
        UtxoView(wallet: wallet, outpoint: wallet.allBalances)
    }
}
*/
