//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

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
    @State private var isTaproot = true
    @State private var signingKeysCount = 1
    @State private var totalKeysCount = 1

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
                Section(header: Text("Type in miniscript:")) {
                    TextEditor(text: $miniscript)
                        .lineLimit(10)
                        .frame(minHeight: 130)
                }
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
                        Text("Legacy non-SegWit")
                        Text("pkh, sh")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isSegWitLegacy) {
                    VStack(alignment: .leading) {
                        Text("Legacy SegWit")
                        Text("sh(wpkh), sh(wsh)")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isSegWit) {
                    VStack(alignment: .leading) {
                        Text("SegWit v0")
                        Text("wpkh, wsh")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                Toggle(isOn: $isTaproot) {
                    VStack(alignment: .leading) {
                        Text("Taproot (SegWit v1)")
                    }
                }
            }
        }
        .frame(minWidth: 266, idealWidth: 333, minHeight: 444, idealHeight: 666, alignment: .topLeading)
        .padding(extraPadding)
        .navigationTitle("New account")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    // data.wallets.append(AccountDisplayInfo(named: name, havingAssets: [], transactions: []))
                    self.presentationMode.wrappedValue.dismiss()
                }) {
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
