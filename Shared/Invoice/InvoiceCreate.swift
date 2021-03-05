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
        let address = try wallet.nextAddress(legacySegWit: legacyFormat).address
        if representation == .url {
            return "bitcoin:\(address)?amount=\(amount)"
        }
        return address
    }
}

struct InvoiceCreate: View {
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
                    Button(action: {
                        #if os(iOS)
                            UIPasteboard.general.string = generatedStringOrError
                        #endif
                        #if os(macOS)
                        NSPasteboard.general.setString(generatedStringOrError, forType: .string)
                        #endif
                    }) {
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

struct InvoiceCreate_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InvoiceCreate(wallet: CitadelVault.embedded.contracts.first!)
        }
    }
}
