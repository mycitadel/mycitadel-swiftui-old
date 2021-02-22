//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

#if os(macOS)
typealias UIColor = NSColor
extension NSColor {
    static let secondaryLabel = NSColor.secondaryLabelColor
}
#endif

struct AddAccountSheet: View {
    @State private var name: String = ""
    @State private var miniscript: String = ""
    @State private var scripting = WalletScripting.publicKey
    @State private var isBare = false
    @State private var isLegacy = false
    @State private var isSegWit = true
    @State private var isSegWitLegacy = false
    @State private var isTaproot = false
    @State private var signingKeysCount = 2
    @State private var totalKeysCount = 3

    @State private var errorSheet = ErrorSheetConfig()

    #if os(macOS)
    @State private var extraPadding = EdgeInsets(top: 13, leading: 13, bottom: 13, trailing: 13)
    #else
    @State private var extraPadding = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    #endif
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                TextField("Account name", text: $name)
            }
            
            Section(header: Picker(selection: $scripting, label: EmptyView()) {
                Text("Single key").tag(WalletScripting.publicKey)
                Text("Multisig").tag(WalletScripting.multisig)
                Text("Miniscript").tag(WalletScripting.miniscript)
            }) {
                
            }
            .pickerStyle(SegmentedPickerStyle())
            
            switch scripting {
            case .publicKey:
                EmptyView()
            case .multisig:
                Section(header: Text("Multisig composition:")) {
                    GroupBox {
                        Stepper(value: $signingKeysCount, in: 1...totalKeysCount) {
                            Text("Require \(signingKeysCount) signatures")
                        }
                        Stepper(value: $totalKeysCount, in: 1...16) {
                            Text("from a set of \(totalKeysCount) keys")
                        }
                    }
                }
            case .miniscript:
                Section(header: Text("Type in miniscript:"), footer: Text("Use key fingerprint in form of `[9af4]` for referencing signing keys in the miniscript code")) {
                    TextEditor(text: $miniscript)
                        .lineLimit(10)
                        .frame(minHeight: 130)
                }
            }

            Section(header: Text("Select signing keys"), footer: Text("It seems you don't have any registered singing keys which are required for the account creation")) {
                Button(action: {}) { Label("Create new signing key", systemImage: "plus") }
                Button(action: {}) { Label("Import existing signing key", systemImage: "square.and.arrow.down") }
            }
            
            Section(header: Text("Allowed descriptors")) {
                Toggle(isOn: $isBare) {
                    VStack(alignment: .leading) {
                        Text("Bare script")
                        Text("pk, bare")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isLegacy) {
                    VStack(alignment: .leading) {
                        Text("Hashed")
                        Text("pkh, sh")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isSegWitLegacy) {
                    VStack(alignment: .leading) {
                        Text("Legacy SegWit (no witness ver)")
                        Text("sh(wpkh), sh(wsh)")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isSegWit) {
                    VStack(alignment: .leading) {
                        Text("SegWit (v0 witness)")
                        Text("wpkh, wsh")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isTaproot) {
                    VStack(alignment: .leading) {
                        Text("Taproot (v1 witness)")
                        Text("tr")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            }
        }
        .frame(minWidth: 266, idealWidth: 333, minHeight: 444, idealHeight: 666, alignment: .topLeading)
        .padding(extraPadding)
        .navigationTitle("Set up current account")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: createContract) {
                    Text("Create").bold()
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
            }
        }
        .alert(isPresented: $errorSheet.presented, content: errorSheet.content)
    }
    
    func createContract() {
        do {
            var citadel = MyCitadelClient.shared.citadel;
            let _ = try citadel.createSingleSig(named: name, descriptor: .segwit, enableRGB: true)
        } catch {
            errorSheet.present(error)
            return
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct AddAccountSheet_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddAccountSheet()
                .previewDevice("iPhone 12 Pro")
        }
    }
}
