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

public enum WalletScripting: Hashable {
    case publicKey
    case multisig
    case miniscript
}

struct CurrentContract: View {
    @State private var name: String = ""
    @State private var miniscript: String = ""
    @State private var scripting = WalletScripting.publicKey
    @State private var descriptorType = DescriptorType.segwit
    @State private var hasRGB = true
    @State private var signingKeysCount = 1
    @State private var signingKeys = []
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
                    Stepper(value: $signingKeysCount, in: 1...signingKeys.count+1) {
                        Text("Require \(signingKeysCount) signatures from:")
                    }
                    Label("Your device-stored key", systemImage: "signature")
                    Button(action: {}) { Label("Add co-signer", systemImage: "square.and.arrow.down") }
                }
            case .miniscript:
                Section(header: Text("Type in miniscript:"), footer: Text("Use key fingerprint in form of `[9af4]` for referencing signing keys in the miniscript code")) {
                    TextEditor(text: $miniscript)
                        .lineLimit(10)
                        .frame(minHeight: 130)
                }
            }

            Section(header: Text("Descriptor & address format")) {
                Button(action: { descriptorType = .segwit }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .opacity(descriptorType == .segwit ? 1 : 0)
                        VStack(alignment: .leading) {
                            Text("SegWit – witness ver 0")
                                .foregroundColor(.primary)
                            Text("In both legacy and new formats")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(scripting == .publicKey ? "P2WPKH" : "P2WSH")
                                .font(.body)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text("(+in-P2SH)")
                                .font(.caption2)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                }
                
                Button(action: { descriptorType = .taproot }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .opacity(descriptorType == .taproot ? 1 : 0)
                        VStack(alignment: .leading) {
                            Text("Taproot – witness ver 1")
                                .foregroundColor(.primary)
                            Text("Yearly preview")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        Spacer()
                        Text("P2TR")
                            .font(.body)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }

                Button(action: { descriptorType = .hashed }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .opacity(descriptorType == .hashed ? 1 : 0)
                        VStack(alignment: .leading) {
                            Text("Legacy – no witness")
                                .foregroundColor(.primary)
                            Text("Requires higher fees")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        Spacer()
                        Text(scripting == .publicKey ? "P2PKH" : "P2SH")
                            .font(.body)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }

                Button(action: { descriptorType = .bare }) {
                    HStack {
                        Image(systemName: "checkmark")
                            .opacity(descriptorType == .bare ? 1 : 0)
                        VStack(alignment: .leading) {
                            Text("\(scripting == .publicKey ? "Bare public key" : "Raw script")")
                                .foregroundColor(.primary)
                            Text("Read-only wallet for ancient miners\nDepricated & not recommended")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        Spacer()
                        Text(scripting == .publicKey ? "P2PK" : "BARE")
                            .font(.body)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            }
            
            Section(footer: Text("RGB is a smart-contracting & digital asset technology that works with Bitcoin on-chain and Lightning network. Turning its support will make wallet incompatible with all software (including other wallets) which does not have RGB support")) {
                Toggle(isOn: $hasRGB) {
                    VStack(alignment: .leading) {
                        Text("Support RGB assets")
                    }
                }
            }
        }
        .frame(minWidth: 266, idealWidth: 333, minHeight: 444, idealHeight: 666, alignment: .topLeading)
        .padding(extraPadding)
        .navigationTitle("Set up current account")
        // .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: createContract) {
                    Text("Create")
                        .bold()
                }
                .disabled(scripting != .publicKey || name.isEmpty)
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
            let _ = try CitadelVault.embedded.createSingleSig(named: name, descriptor: .segwit, enableRGB: true)
        } catch {
            errorSheet.present(error)
            return
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct CurrentContract_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CurrentContract()
                .previewDevice("iPhone 12 Pro")
        }
    }
}
