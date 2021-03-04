//
//  CreateInvoice.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/24/21.
//

import SwiftUI
import Combine
import MyCitadelKit

struct InvoiceDetails: View {
    @StateObject private var citadel = CitadelVault.embedded!
    @ObservedObject var invoiceConfig: InvoiceConfig
    private var amountName: String {
        invoiceConfig.amountType == .perItem ? "Price" : "Amount"
    }
    
    #if os(iOS)
    private let listStyle = InsetGroupedListStyle()
    #else
    private let listStyle = SidebarListStyle()
    #endif
    
    var body: some View {
        List {
            Section(header: Text(amountName)) {
                Picker(selection: $invoiceConfig.amountType, label: EmptyView()) {
                    Text("Arbitrary").tag(AmountType.arbitrary)
                    Text("Fixed").tag(AmountType.fixed)
                    Text("Per item").tag(AmountType.perItem).disabled(invoiceConfig.repeated == .recurrent)
                }.pickerStyle(SegmentedPickerStyle())
                if invoiceConfig.amountType != .arbitrary {
                    HStack(alignment: .lastTextBaseline) {
                        Text("\(amountName): ")
                            .font(.title)
                        AmountField(
                            placeholder: "Specify \(amountName.lowercased())",
                            units: invoiceConfig.units,
                            amount: $invoiceConfig.amount
                        )
                            .font(.title)
                        Button(action: { invoiceConfig.nextNomination() }) { Text(invoiceConfig.assetName) }
                            .foregroundColor(.secondary)
                    }
                }
                if invoiceConfig.amountType == .perItem && invoiceConfig.repeated != .recurrent {
                    Stepper(value: $invoiceConfig.quantity.byDefault, in: 1...60) {
                        Text("Default to \(invoiceConfig.quantity.byDefault) item(s)")
                    }
                    HStack {
                        Toggle("", isOn: $invoiceConfig.quantity.limitMin).labelsHidden()
                        Stepper(value: $invoiceConfig.quantity.min, in: 1...60) {
                            Text(invoiceConfig.quantity.limitMin ? "min \(invoiceConfig.quantity.min) item(s)" : "require minimum")
                        }
                        .disabled(!invoiceConfig.quantity.limitMin)
                    }
                    HStack {
                        Toggle("", isOn: $invoiceConfig.quantity.limitMax).labelsHidden()
                        Stepper(value: $invoiceConfig.quantity.max, in: 1...60) {
                            Text(invoiceConfig.quantity.limitMax ? "max \(invoiceConfig.quantity.max) item(s)" : "limit maximum")
                        }
                        .disabled(!invoiceConfig.quantity.limitMax)
                    }
                }
            }
            
            if invoiceConfig.amountType != .arbitrary {
                Section(header: Toggle("Volatility protection", isOn: $invoiceConfig.volatilityProtection)) {
                    if invoiceConfig.volatilityProtection {
                        Stepper(value: $invoiceConfig.currency.tolerance, in: 1...25) {
                            Text("Tolerate \(invoiceConfig.currency.tolerance)% rate change")
                        }
                        Picker(selection: $invoiceConfig.currency.provider, label: Text("Price privider")) {
                            Text("Bitfinex").tag(PriceProvider.bitfinex)
                            Text("Kraken").tag(PriceProvider.kraken)
                            Text("Binance").tag(PriceProvider.binance)
                        }
                    }
                }

                Section(header: Text("Unit of accounting")) {
                    Button(action: {
                            invoiceConfig.assetId = citadel.network.nativeAssetId();
                            invoiceConfig.units = .accounting
                    }) {
                        Label {
                            Text(citadel.network.coinName())
                        } icon: {
                            Image(systemName: "checkmark").opacity(invoiceConfig.asset.isNative && invoiceConfig.units == .accounting ? 1 : 0)
                        }
                    }.foregroundColor(.primary)
                    Button(action: {
                            invoiceConfig.assetId = citadel.network.nativeAssetId();
                            invoiceConfig.units = .atomic
                    }) {
                        Label {
                            Text(citadel.network.localizedSatoshis)
                        } icon: {
                            Image(systemName: "checkmark").opacity(invoiceConfig.asset.isNative && invoiceConfig.units == .atomic ? 1 : 0)
                        }
                    }.foregroundColor(.primary)
                }
            } else {
                Section(header: Text("Native asset")) {
                    Button(action: { invoiceConfig.assetId = citadel.network.nativeAssetId() }) {
                        Label {
                            Text(citadel.network.coinName())
                        } icon: {
                            Image(systemName: "checkmark").opacity(invoiceConfig.asset.isNative ? 1 : 0)
                        }
                    }.foregroundColor(.primary)
                }
            }
            
            Section(header: Text("RGB assets"), footer: VStack {
                if citadel.assets.count > 1 {
                    EmptyView()
                } else {
                    Text("No known RGB assets. Please import asset genesis with the import function")
                }
            }) {
                ForEach(Array(citadel.assets.values).filter { !$0.isNative }, id: \.id) { asset in
                    Button(action: { invoiceConfig.assetId = asset.id }) {
                        Label {
                            Text(asset.name)
                        } icon: {
                            Image(systemName: "checkmark").opacity(invoiceConfig.assetId == asset.id ? 1 : 0)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .listStyle(listStyle)
        .navigationTitle("Invoice amount")
    }
}

struct InvoiceDetails_Previews: PreviewProvider {
    @StateObject static var config: InvoiceConfig = {
        let config = InvoiceConfig()
        config.useExpiry = true
        config.useExpiry = true
        config.amountType = .perItem
        config.amount = "1"
        config.repeated = .multiple
        config.quantity.limitMin = true
        config.quantity.limitMax = true
        config.usePurpose = true
        config.useMerchant = true
        config.useDetails = true
        return config
    }()
    
    static var previews: some View {
        NavigationView {
            InvoiceDetails(invoiceConfig: Self.config)
        }
    }
}
