//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import CodeScanner
import MyCitadelKit

struct Import: View {
    public enum Category: String {
        case all = ""
        case assetId = "rgb1"
        case schemaId = "sch1"
        case genesis = "genesis1"
        case schema = "schema1"
        case consignment = "consignment1"
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var importName: String
    var category: Category

    @State private var bechString: String = ""
    @State private var recognizedAs: String = "<no data>"
    @State private var recognitionMessages: [(String, String)] = []
    @State private var recognitionDetails: [String] = []
    @State private var recognitionErrors: [String] = []
    @State private var canImport: Bool = false
    @State private var errorSheet: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Label("Enter bech32 \(importName) string:", systemImage: "pencil")
                    .font(.headline)

                Spacer()

                TextEditor(text: $bechString)
                    .font(.title2)
                    .lineSpacing(6)
                    .autocapitalization(.none)
                    .textContentType(.none)
                    .disableAutocorrection(true)
                    .padding(0)
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(UIColor.lightGray), lineWidth: 0.5))
                    .onChange(of: bechString, perform: parseBech32)
                
                Text("NB: string must start with \"\(category.rawValue)\"")
                    .font(.footnote)

                Divider()

                Label("Or scan a QR code:", systemImage: "qrcode.viewfinder")
                    .font(.headline)
                CodeScannerView(codeTypes: [.qr], simulatedData: "genesis1qyfe883hey6jrgj2xvk5g3dfmfqfzm7a4wez4pd2krf7ltsxffd6u6nrvjvvnc8vt9llmp7663pgututl9heuwaudet72ay9j6thc6cetuvhxvsqqya5xjt2w9y4u6sfkuszwwctnrpug5yjxnthmr3mydg05rdrpspcxysnqvvqpfvag2w8jxzzsz9pf8pjfwf0xvln5z7w93yjln3gcnyxsa04jsf2p8vu4sxgppfv0j9qer9wpmqlum5uyzrzwven3euhvknz398yv7n7vvfnxzp26eryuz0vxgueqrftgqxgv90dp3sgxxqkzggryve5s8l0nt94xne7pv6ksln9wj3ekel753vcwhvksuud2037k5lmj2k5cmut4clzfzucds5h4aqt4cx6pyqtqgsqq0e4wu", completion: parseBechQr)
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(UIColor.lightGray), lineWidth: 0.5))

               
                Group {
                    HStack {
                        Label(recognitionErrors.count > 0 ? "Recognition" : "Recognized as", systemImage: "perspective")
                            .font(.headline)
                        Spacer()
                        Text(recognizedAs)
                            .font(.body)
                    }
                    ForEach(recognitionDetails, id: \.self) { detail in
                        Text(detail)
                            .font(.subheadline)
                            .padding(.leading, 32)
                    }
                    ForEach(recognitionMessages, id: \.1) { (label, message) in
                        HStack {
                            Text(label)
                                .font(.headline)
                            Spacer()
                            Text(message)
                                .font(.body)
                        }
                        .padding(.vertical, 3)
                        .padding(.leading, 32)
                    }
                    ForEach(recognitionErrors, id: \.self) { error in
                        Text(error)
                            .font(.subheadline)
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
                    Button(action: importBech32) {
                        Text("Import")
                    }
                    .disabled(!canImport)
                }
            }
            .alert(isPresented: $errorSheet, content: {
                Alert(title: Text("Error during import"), message: Text(errorMessage), dismissButton: .cancel())
            })
        }
    }
    
    private func parseBech32(_ bech32: String) {
        let info = Bech32Info(bech32)

        canImport = false
        recognizedAs = info.details.name()
        recognitionMessages = []
        recognitionDetails = []

        switch info.details {
        case .unknown:
            recognizedAs = "incorrect data"
            recognitionErrors = [info.parseReport]
        case .rgb20Asset(let asset):
            recognitionDetails = [asset.id]
            recognitionMessages = [
                ("Ticker", asset.ticker),
                ("Name", asset.name),
                ("Known supply", String(asset.knownCirculatingAssets))
            ]
            canImport = true
        default: break
        }
    }
    
    private func parseBechQr(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
        case .success(let bech32):
            bechString = bech32
            parseBech32(bech32)
            canImport = true
        case .failure(let error):
            recognizedAs = "incorrect data"
            canImport = false
            recognitionMessages = []
            recognitionDetails = []
            recognitionErrors = ["QR error: \(error.localizedDescription)"]
        }
    }
    
    private func importBech32() {
        let info = Bech32Info(bechString)
        do {
            switch info.details {
            case .rgb20Asset(_):
                let asset = try MyCitadelClient.shared!.importAsset(bech32: bechString)
            default:
                break
            }
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            errorSheet = true
            errorMessage = error.localizedDescription
        }
    }
}

struct AssetsSheet_Previews: PreviewProvider {
    static var previews: some View {
        Import(importName: "asset", category: .genesis)
    }
}
