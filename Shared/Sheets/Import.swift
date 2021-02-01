//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import CodeScanner

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

    @State private var bechString: String = "genesis1fvaldknfv"

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Label("Enter bech32 \(importName) string:", systemImage: "pencil")
                    .font(.headline)
                    

                Spacer()

                TextEditor(text: $bechString)
                    .font(.title2)
                    .lineSpacing(8)
                    .autocapitalization(.none)
                    .textContentType(.none)
                    .padding(0)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: bechString, perform: parseBech32)
                
                Text("NB: string must start with \"\(category.rawValue)\"")
                    .font(.footnote)

                Divider()

                Label("Or scan a QR code:", systemImage: "qrcode.viewfinder")
                    .font(.headline)
                CodeScannerView(codeTypes: [.qr], simulatedData: "genesis1", completion: parseBechQr)
                
                Divider()
                
                HStack {
                    Label("Recognized as:", systemImage: "perspective")
                        .font(.headline)
                    Spacer()
                    Text("RGB genesis")
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
                }
            }
        }
    }
    
    private func parseBech32(value: String) {
        
    }
    
    private func parseBechQr(result: Result<String, CodeScannerView.ScanError>) {
        
    }
    
    private func importBech32() {
        
    }
}

struct AssetsSheet_Previews: PreviewProvider {
    static var previews: some View {
        Import(importName: "asset", category: .genesis)
    }
}
