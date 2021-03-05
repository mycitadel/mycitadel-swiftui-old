//
//  AddressView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/5/21.
//

import SwiftUI
import MyCitadelKit

struct AddressView: View {
    @Environment(\.currencyUoA) var fiatUoA: String

    let wallet: WalletContract

    @State var addressDerivation: AddressDerivation

    private var address: String {
        addressDerivation.address
    }
    private var path: String {
        addressDerivation.path
    }
    private var allocations: [Allocation] {
        wallet.addressAllocations(addressDerivation.address)
    }
    private var assetBalances: [(RGB20Asset, Double)] {
        allocations.assetBalances.compactMap { assetId, amount in
            guard let asset = CitadelVault.embedded.assets[assetId] as? RGB20Asset else { return nil }
            if amount == 0 {
                return nil
            }
            return (asset, amount)
        }
    }
    private var outpoints: [OutPoint] {
        Array(allocations.outpointBalances.keys)
    }
    private var network: BitcoinNetwork {
        CitadelVault.embedded.network
    }
    private var nativeAsset: NativeAsset {
        CitadelVault.embedded.nativeAsset
    }
    private var bitcoins: Double {
        allocations.bitcoinBalance(network: network)
    }
    private var satoshis: UInt64 {
        allocations.satoshisBalance(network: network)
    }
    private var currencyEquivalent: Double {
        allocations.bitcoinBalance(network: network) * nativeAsset.fiatExchangeRate
    }

    var body: some View {
        List {
            Section {
                DetailsCell(title: "Wallet", details: wallet.name)
            }

            Section {
                SubheadingCell(title: "Address", details: address, clipboardCopy: true)
                DetailsCell(title: "Derivation index", details: path)
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
            
            Section(header: Text("Unspent transaction outputs (UTXOs)"), footer: utxosFooter) {
                ForEach(outpoints) { outpoint in
                    NavigationLink(destination: UtxoView(wallet: wallet, outpoint: outpoint, addressDerivation: addressDerivation)) {
                        VStack(alignment: .leading) {
                            Text(outpoint.txid)
                                .font(.subheadline)
                                .truncationMode(.middle)
                                .lineLimit(1)
                            HStack(alignment: .lastTextBaseline) {
                                Spacer()
                                Text("Output number:").font(.caption).foregroundColor(.secondary)
                                Text("\(outpoint.vout)").font(.body)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Address details")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
    
    var utxosFooter: some View {
        if outpoints.count == 0 {
            return Text("No unspent outputs")
        } else {
            return Text("")
        }
    }

    private var index: Int? {
        wallet.usedAddresses.firstIndex { $0 == addressDerivation }
    }
    private var prev: AddressDerivation? {
        guard let index = index else { return nil }
        if index <= 0 {
            return nil
        }
        return wallet.usedAddresses[index - 1]
    }
    private var next: AddressDerivation? {
        guard let index = index else { return nil }
        if index + 1 >= wallet.usedAddresses.count {
            return nil
        }
        return wallet.usedAddresses[index + 1]
    }
    
    func movePrev() {
        if let prev = prev {
            addressDerivation = prev
        }
    }
    func moveNext() {
        if let next = next {
            addressDerivation = next
        }
    }
}

struct AddressView_Previews: PreviewProvider {
    static let wallet = CitadelVault.embedded.contracts.first!
    static var previews: some View {
        AddressView(wallet: wallet, addressDerivation: wallet.usedAddresses.first!)
    }
}
