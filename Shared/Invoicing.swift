//
//  CreateInvoice.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/24/21.
//

import SwiftUI
import Combine
import MyCitadelKit

enum RepeatedPayments: Hashable {
    case single
    case multiple
    case recurrent
}

enum RecurrentPayments: Equatable {
    case bySecond(UInt8)
    case byMinute(UInt8)
    case byHour(UInt8)
    case byDay(UInt8)
    case byWeek(UInt8)
    case byMonth(UInt8)
    case byYear(UInt8)
}

enum AmountType {
    case arbitrary
    case fixed
    case perItem
}

struct CurrencyData {
    var iso4217: String = "USD"
    var tolerance: UInt8 = 0
    var provider: PriceProvider = .bitfinex
}

enum PriceProvider {
    case bitfinex
    case kraken
    case binance
}

struct Quantity {
    var limitMin: Bool = false
    var min: UInt32 = 1
    var limitMax: Bool = false
    var max: UInt32 = 1
    var byDefault: UInt32 = 1
}

enum InvoiceRepresentation {
    case address
    case url
    case lnpbpInvoice
}

enum Units {
    case accounting
    case atomic
    case currency
}

final class InvoiceConfig: ObservableObject {
    @Published var legacyFormat: Bool = false
    @Published var amountType: AmountType = .arbitrary
    @Published var amount: String = "0"
    @Published var units: Units = .accounting
    @Published var assetId: String = CitadelVault.embedded.nativeAsset.id
    @Published var repeated: RepeatedPayments = .single
    @Published var recurrent: RecurrentPayments = .byDay(1)
    @Published var quantity: Quantity = Quantity()
    @Published var addPersonalServer: Bool = false
    @Published var addWalletServer: Bool = false
    @Published var useExpiry: Bool = false
    @Published var expiry: Date = Date()
    @Published var useMerchant: Bool = false
    @Published var merchant: String = ""
    @Published var usePurpose: Bool = false
    @Published var purpose: String = ""
    @Published var useDetails: Bool = false
    @Published var detailsUrl: String = ""
    @Published var volatilityProtection: Bool = false
    @Published var currency: CurrencyData = CurrencyData()
    
    var representation: InvoiceRepresentation {
        if assetId != CitadelVault.embedded!.nativeAsset.id ||
            repeated != .single ||
            amountType == .perItem ||
            addPersonalServer ||
            addWalletServer ||
            useExpiry ||
            useMerchant ||
            usePurpose ||
            useDetails ||
            volatilityProtection
        {
            return .lnpbpInvoice
        }
        if amountType == .fixed {
            return .url
        }
        return .address
    }
    
    var asset: Asset {
        CitadelVault.embedded.assets[assetId]!
    }
    
    var assetName: String {
        if units == .currency {
            return currency.iso4217
        }
        if units == .atomic && asset.isNative {
            return CitadelVault.embedded.network.localizedSats
        }
        return asset.ticker
    }
    
    func nextNomination() {
        switch units {
        case .accounting where asset.isNative:
            units = .atomic
        case .accounting:
            units = .currency
        case .atomic:
            units = .currency
        case .currency:
            units = .accounting
        }
    }
    
    func generate(forWallet wallet: WalletContract) throws -> String {
        if representation == .lnpbpInvoice {
            return try wallet.invoice(
                usingFormat: wallet.hasUtxo ? .addressUtxo : .descriptor,
                nominatedIn: asset,
                amount: Double(amount) ?? 0
            )
        }
        let address = try wallet.address(useLegacySegWit: legacyFormat).address
        if representation == .url {
            return "bitcoin:\(address)?amount=\(amount)"
        }
        return address
    }
}

struct CreateInvoice: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var invoiceConfig = InvoiceConfig()
    
    private var asset: Asset {
        CitadelVault.embedded.assets[invoiceConfig.assetId]!
    }
    private var invoiceName: String {
        return invoiceConfig.representation != .lnpbpInvoice ? "address" : "invoice"
    }

    private var generatedString: String? {
        try? invoiceConfig.generate(forWallet: wallet)
    }
    private var generatedStringOrError: String {
        do {
            return try invoiceConfig.generate(forWallet: wallet)
        } catch {
            return error.localizedDescription
        }
    }
    private var dataColor: Color {
        generatedString == nil ? .red : .blue
    }

    let wallet: WalletContract

    init(wallet: WalletContract, assetId: String? = nil) {
        self.wallet = wallet
        if assetId != nil && assetId != "" {
            invoiceConfig.assetId = assetId!
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text(
                    "Since you do not own any bitcoins yet, the sender will also have " +
                    "to pay you a small amount of bitcoins"
                )) {
                    NavigationLink(destination: InvoiceDetails(invoiceConfig: invoiceConfig)) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Request")
                            Spacer()
                            if invoiceConfig.amountType != .arbitrary {
                                Text(invoiceConfig.amount).bold()
                            }
                            Text(invoiceConfig.assetName)
                            if invoiceConfig.units == .currency {
                                Text(" in \(asset.ticker)").foregroundColor(.secondary)
                            }
                        }
                    }
                    NavigationLink(destination: InvoiceAdvanced(invoiceConfig: invoiceConfig)) {
                        Text("Advanced settings")
                    }
                }
                
                Section(header: Text("Your \(invoiceName)")) {
                    Toggle(isOn: $invoiceConfig.legacyFormat) {
                        Text("Support pre-SegWit wallets")
                    }
                    Button(action: { UIPasteboard.general.string = generatedStringOrError }) {
                        HStack {
                            Text(generatedStringOrError)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "doc.on.doc")
                        }
                    }.foregroundColor(dataColor)
                    if let generatedString = generatedString {
                        generateQRCode(from: generatedString)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(1, contentMode: .fit)
                    }
                    
                    // With the current MyCitadel Node business logic we always assume
                    // that generated address or invoice was used and will never generate
                    // the same address twice. It also provides `markUnused` function
                    // which we may support in the future using the buttons below
                    /*
                    Button(action: {}) {
                        HStack {
                            Spacer()
                            Text("I have used the \(invoiceName)")
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(13)
                    }
                    Button(action: {}) {
                        HStack {
                            Spacer()
                            Text("\(invoiceName.capitalized) was not used")
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(13)
                    }
                    */
                }
            }
            .navigationTitle("Receive funds")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { self.presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

struct InvoiceDetails: View {
    @StateObject private var citadel = CitadelVault.embedded!
    @ObservedObject var invoiceConfig: InvoiceConfig
    private var amountName: String {
        invoiceConfig.amountType == .perItem ? "Price" : "Amount"
    }
    
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
                        TextField("Specify \(amountName.lowercased())", text: $invoiceConfig.amount)
                            .font(.title)
                            .keyboardType(invoiceConfig.units == .atomic ? .numberPad : .decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onReceive(Just(invoiceConfig.amount)) { newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue {
                                    invoiceConfig.amount = filtered
                                }
                                if invoiceConfig.units == .atomic {
                                    let amount = "\(UInt64(invoiceConfig.amount) ?? 0)"
                                    if amount != invoiceConfig.amount {
                                        invoiceConfig.amount = amount
                                    }
                                } else {
                                    let amount = "\(Double(invoiceConfig.amount) ?? 0)"
                                    if amount != invoiceConfig.amount {
                                        invoiceConfig.amount = amount
                                    }
                                }
                            }
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
                        Label(citadel.network.coinName(),
                              systemImage: invoiceConfig.asset.isNative && invoiceConfig.units == .accounting ? "checkmark" : "")
                    }.foregroundColor(.primary)
                    Button(action: {
                            invoiceConfig.assetId = citadel.network.nativeAssetId();
                            invoiceConfig.units = .atomic
                    }) {
                        Label(citadel.network.localizedSatoshis,
                              systemImage: invoiceConfig.asset.isNative && invoiceConfig.units == .atomic ? "checkmark" : "")
                    }.foregroundColor(.primary)
                }
            } else {
                Section(header: Text("Native asset")) {
                    Button(action: { invoiceConfig.assetId = citadel.network.nativeAssetId() }) {
                        Label(citadel.network.coinName(),
                              systemImage: invoiceConfig.asset.isNative ? "checkmark" : "")
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
                ForEach(Array(citadel.assets.values), id: \.id) { asset in
                    if !asset.isNative {
                        Button(action: { invoiceConfig.assetId = asset.id }) {
                            Label(asset.name,
                                  systemImage: invoiceConfig.assetId == asset.id ? "checkmark" : "")
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
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

struct CreateInvoice_Previews: PreviewProvider {
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
                CreateInvoice(wallet: CitadelVault.embedded.contracts.first!)
            }

            NavigationView {
                InvoiceDetails(invoiceConfig: Self.config)
            }

            NavigationView {
                InvoiceAdvanced(invoiceConfig: Self.config)
            }
        }
    }
}
