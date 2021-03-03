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

struct InvoiceAdvanced: View {
    @ObservedObject var invoiceConfig: InvoiceConfig
    @State private var frequency: UInt8 = 1 {
        didSet {
            updateRecurrency()
        }
    }
    
    private func frequencyName(_ interval: String) -> String {
        frequency == 1 ? interval : "\(frequency) \(interval)s"
    }
    private func checkMark(by name: String) -> String {
        switch (name, invoiceConfig.recurrent) {
        case ("second", .bySecond(_)): return "checkmark"
        case ("minute", .byMinute(_)): return "checkmark"
        case ("hour", .byHour(_)): return "checkmark"
        case ("day", .byDay(_)): return "checkmark"
        case ("week", .byWeek(_)): return "checkmark"
        case ("month", .byMonth(_)): return "checkmark"
        case ("year", .byYear(_)): return "checkmark"
        default: return ""
        }
    }
    private func updateRecurrency() {
        switch invoiceConfig.recurrent {
        case .bySecond(_): invoiceConfig.recurrent = .bySecond(frequency)
        case .byMinute(_): invoiceConfig.recurrent = .byMinute(frequency)
        case .byHour(_): invoiceConfig.recurrent = .byHour(frequency)
        case .byDay(_): invoiceConfig.recurrent = .byDay(frequency)
        case .byWeek(_): invoiceConfig.recurrent = .byWeek(frequency)
        case .byMonth(_): invoiceConfig.recurrent = .byMonth(frequency)
        case .byYear(_): invoiceConfig.recurrent = .byYear(frequency)
        }
    }
   
    var body: some View {
        Form {
            Section(header: VStack(alignment: .leading) {
                Text("Allow payment to be")
                Picker("", selection: $invoiceConfig.repeated) {
                    Text("Single").tag(RepeatedPayments.single)
                    Text("Multiple").tag(RepeatedPayments.multiple)
                    Text("Regular").tag(RepeatedPayments.recurrent)
                }
                .pickerStyle(SegmentedPickerStyle())
            }) {
                if invoiceConfig.repeated == .recurrent {
                    Stepper(value: $frequency, in: 1...60) {
                        Text("should happen each")
                    }
                    Button(action: { invoiceConfig.recurrent = .bySecond(frequency) }) {
                        Label(frequencyName("second"), systemImage: checkMark(by: "second"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byMinute(frequency) }) {
                        Label(frequencyName("minute"), systemImage: checkMark(by: "minute"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byHour(frequency) }) {
                        Label(frequencyName("hour"), systemImage: checkMark(by: "hour"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byDay(frequency) }) {
                        Label(frequencyName("day"), systemImage: checkMark(by: "day"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byWeek(frequency) }) {
                        Label(frequencyName("week"), systemImage: checkMark(by: "week"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byMonth(frequency) }) {
                        Label(frequencyName("month"), systemImage: checkMark(by: "month"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byYear(frequency) }) {
                        Label(frequencyName("year"), systemImage: checkMark(by: "year"))
                    }.foregroundColor(.primary)
                }
                /*
                Toggle(isOn: $invoiceConfig.multiple) {
                    Text("Allow multple paymets")
                }
                 */
            }

            Section(header: Toggle(isOn: $invoiceConfig.usePurpose) {
                Text("Describe invoice purpose")
            }) {
                if invoiceConfig.usePurpose {
                    TextField("Write some purpose explanation", text: $invoiceConfig.purpose)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                }
            }

            Section(header: Toggle(isOn: $invoiceConfig.useMerchant) {
                Text("Name yourself")
            }) {
                if invoiceConfig.useMerchant {
                    TextField("Yourself or your company", text: $invoiceConfig.merchant)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                }
            }

            Section(header: Toggle(isOn: $invoiceConfig.useExpiry) {
                Text("Set expiration")
            }) {
                if invoiceConfig.useExpiry {
                    DatePicker(selection: $invoiceConfig.expiry, label: { EmptyView() })
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
        }
        .navigationTitle("Advanced options")
    }
}

struct InvoiceAdvance_Previews: PreviewProvider {
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
        Group {
            NavigationView {
                InvoiceDetails(invoiceConfig: Self.config)
            }

            NavigationView {
                InvoiceAdvanced(invoiceConfig: Self.config)
            }
        }
    }
}
