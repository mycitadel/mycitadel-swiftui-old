//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
#if os(iOS)
import CodeScanner
#endif
import MyCitadelKit

struct Import: View {
    public enum Category: String {
        case all = ""
        case assetId = "rgb1"
        case schemaId = "sch1"
        case genesis = "genesis1"
        case schema = "schema1"
        case consignment = "consignment1"
        case invoice = "i1 bc1 tb1 bcrt1 1 2 3 n m bitcoin:"
    }
    
    private enum ImportAction: Hashable {
        case pay
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var importName: String
    var category: Category

    @Binding var invoice: Invoice?
    @Binding var dataString: String
    @State var wallet: WalletContract?
    @State private var recognizedAs: String = "<no data>"
    @State private var recognitionMessages: [(String, String)] = []
    @State private var recognitionDetails: [String] = []
    @State private var recognitionErrors: [String] = []
    @State private var canImport: Bool = false
    @State private var errorSheet: Bool = false
    @State private var errorMessage: String = ""
    @State private var displayQR: Bool = true
    @State private var importAction: ImportAction? = nil

    var textEditorInner: some View {
        TextEditor(text: $dataString)
            .font(.title2)
            .lineSpacing(6)
            .disableAutocorrection(true)
            .padding(0)
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(UIColor.lightGray), lineWidth: 0.5))
            .onChange(of: dataString, perform: parseInput)
    }
    
    var textEditor: some View {
        #if os(macOS)
        return textEditorInner
        #else
        return textEditorInner.autocapitalization(.none)
        #endif
    }
    
    var body: some View {
        NavigationView {
            if importAction == .pay {
                NavigationLink("Payment", destination: PaymentView(wallet: wallet, invoice: invoice!, invoiceString: dataString), tag: .pay, selection: $importAction)
            }

            VStack(alignment: .leading) {
                Label("Enter bech32 \(importName) string:", systemImage: "pencil")
                    .font(.headline)

                Spacer()

                textEditor

                if category != .all && !recognitionErrors.isEmpty {
                    HStack(alignment: .firstTextBaseline) {
                        Text("NB: string must start with")
                        Text(category.rawValue).italic()
                    }
                    .font(.footnote)
                }

                Divider()

                #if os(iOS)
                if displayQR {
                    Label("Or scan a QR code:", systemImage: "qrcode.viewfinder")
                        .font(.headline)
                    CodeScannerView(codeTypes: [.qr], simulatedData: "genesis1qyfe883hey6jrgj2xvk5g3dfmfqfzm7a4wez4pd2krf7ltsxffd6u6nrvjvvnc8vt9llmp7663pgututl9heuwaudet72ay9j6thc6cetuvhxvsqqya5xjt2w9y4u6sfkuszwwctnrpug5yjxnthmr3mydg05rdrpspcxysnqvvqpfvag2w8jxzzsz9pf8pjfwf0xvln5z7w93yjln3gcnyxsa04jsf2p8vu4sxgppfv0j9qer9wpmqlum5uyzrzwven3euhvknz398yv7n7vvfnxzp26eryuz0vxgueqrftgqxgv90dp3sgxxqkzggryve5s8l0nt94xne7pv6ksln9wj3ekel753vcwhvksuud2037k5lmj2k5cmut4clzfzucds5h4aqt4cx6pyqtqgsqq0e4wu", completion: parseQr)
                        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(UIColor.lightGray), lineWidth: 0.5))
                }
                #endif
                
                Group {
                    HStack {
                        Label(recognitionErrors.count > 0 ? "Recognition" : "Recognized as", systemImage: "perspective")
                            .font(.headline)
                        Spacer()
                        Text(recognizedAs)
                            .font(.body)
                    }
                    ForEach(recognitionDetails, id: \.self) { detail in
                        HStack {
                            Spacer()
                            Text(detail)
                                .font(.subheadline)
                                .truncationMode(.middle)
                                .lineLimit(1)
                        }
                    }
                    ForEach(recognitionMessages, id: \.1) { (label, message) in
                        HStack(alignment: .firstTextBaseline) {
                            Text(label)
                                .font(.headline)
                                .layoutPriority(1)
                            Spacer()
                            Text(message)
                                .font(.body)
                                .truncationMode(.middle)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 3)
                        .padding(.leading, 32)
                    }
                    ForEach(recognitionErrors, id: \.self) { error in
                        Spacer()
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .italic()
                            .padding(.leading, 32)
                    }
                }
            }
            .padding(.all)
            .navigationTitle("Import \(importName)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: importData) {
                        Text("Import")
                    }
                    .disabled(!canImport)
                }
            }
            .alert(isPresented: $errorSheet, content: {
                Alert(title: Text("Error during import"), message: Text(errorMessage), dismissButton: .cancel())
            })
            .onAppear {
                if !dataString.isEmpty {
                    parseData(dataString)
                }
            }
        }
    }
    
    private func parseData(_ inputString: String) {
        let info = UniversalParser(inputString)

        canImport = false
        recognizedAs = info.parsedData.localizedDescription
        recognitionMessages = []
        recognitionDetails = []
        recognitionErrors = []

        switch info.parsedData {
        case .unknown:
            recognizedAs = "incorrect data"
            recognitionErrors = [info.parseReport]
        case .rgb20Asset(let asset):
            recognitionDetails = [asset.id]
            recognitionMessages = [
                ("Ticker", asset.ticker),
                ("Name", asset.name),
                ("Known supply", String(asset.knownIssued ?? 0))
            ]
            canImport = category == .genesis || category == .all
        case .address(let address):
            if address.isBIP21 {
                recognitionDetails = ["BIP21 bitcoin invoice"]
            } else {
                recognitionDetails = ["\(address.encoding.name)-encoded"]
            }
            if let amount = address.amount {
                recognitionMessages.append(("Amount", "\(amount) \(CitadelVault.embedded!.network.ticker())"))
            }
            if let label = address.label {
                recognitionMessages.append(("Beneficiary", label))
            }
            if let message = address.message {
                recognitionMessages.append(("Description", message))
            }
            recognitionMessages.append(contentsOf: [
                (address.format.localizedPayload, address.payload),
                ("Format", address.format.rawValue),
                ("Witness version", address.witnessVer.localizedDescription),
                ("Network", address.network.localizedName),
            ])
            canImport = category == .invoice || category == .all
        case .lnbpInvoice(let invoice):
            recognitionMessages = [
                ("Pay to", invoice.beneficiary),
                ("Amount", invoice.amount != nil ? String(invoice.amount!) : "any"),
                ("Asset", invoice.assetId ?? CitadelVault.embedded.network.coinName()),
            ]
            if let label = invoice.merchant {
                recognitionMessages.append(("Beneficiary", label))
            }
            if let message = invoice.purpose {
                recognitionMessages.append(("Description", message))
            }
            canImport = category == .invoice || category == .all
        case .rgbConsignment(let info):
            recognitionDetails = ["allows accepting RGB payments & state transfers"]
            recognitionMessages = [
                ("Asset Id", info.asset.id),
                ("Asset name", info.asset.name),
                ("Known circulation", "\(info.asset.knownCirculating) \(info.asset.ticker)"),
                ("Schema Id", info.schemaId),
                ("Stats", "\(info.transactionsCount) txes, \(info.transitionsCount) transitions, \(info.extensionsCount) endpoints")
            ]
            canImport = category == .consignment || category == .all
        default: break
        }
        
        if !canImport && recognitionErrors.isEmpty {
            recognitionErrors.append("This type of data can't be imported in the given context")
        }
    }
    
    private func parseInput(_ inputString: String) {
        displayQR = false
        parseData(inputString)
    }
    
    #if os(iOS)
    private func parseQr(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
        case .success(let bech32):
            dataString = bech32
            parseData(bech32)
            canImport = true
        case .failure(let error):
            recognizedAs = "incorrect data"
            canImport = false
            recognitionMessages = []
            recognitionDetails = []
            recognitionErrors = ["QR error: \(error.localizedDescription)"]
        }
    }
    #endif
    
    private func importData() {
        let info = UniversalParser(dataString)
        do {
            switch info.parsedData {
            case .rgb20Asset(_):
                let _ = try CitadelVault.embedded.importAsset(fromString: dataString)
                self.presentationMode.wrappedValue.dismiss()
            case .address(let address):
                var invoice = Invoice(beneficiary: address.address)
                invoice.amountString = address.value != nil ? String(address.value!) : "any"
                invoice.merchant = address.label
                invoice.purpose = address.message
                self.invoice = invoice
                importAction = .pay
            case .lnbpInvoice(let invoice):
                self.invoice = invoice
                importAction = .pay
            default:
                self.presentationMode.wrappedValue.dismiss()
                break
            }
        } catch {
            errorSheet = true
            errorMessage = error.localizedDescription
        }
    }
}

struct AssetsSheet_Previews: PreviewProvider {
    @State static private var invoice: Invoice? = nil
    @State static private var scannedString: String = ""
    static var previews: some View {
        Import(importName: "asset", category: .genesis, invoice: $invoice, dataString: $scannedString)
    }
}
