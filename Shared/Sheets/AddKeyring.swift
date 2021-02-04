//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AddKeyringSheet: View {
    enum KeyType {
        case xCoordOnly
        case compressed
        case uncompressed
    }
    
    enum KeyStructure {
        case extended
        case single
    }
    
    @Environment(\.presentationMode) var presentationMode

    @State private var keyName: String = ""
    @State private var keyType: KeyType = .xCoordOnly
    @State private var keyStructure: KeyStructure = .extended

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("This will create a new signing key backed by the pair of private and public key. The public key will be kept hot on this device or stored on the hardware wallet. If you'd like to have a cold stored private key or use a read-only wallet please use “import signing key” feature for providning (extended) public key data")) {
                }

                Section(header: Text("Key name:").padding(.top, 20)) {
                    TextField("for instance the name of this device", text: $keyName)
                }

                Section(header: VStack(alignment: .leading) {
                    Text("Select key style:")
                        .padding(.top, 20)
                    Picker(selection: $keyType, label: EmptyView()) {
                        Text("X-coord only").tag(KeyType.xCoordOnly)
                        Text("Compressed").tag(KeyType.compressed)
                        Text("Uncompressed").tag(KeyType.uncompressed)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }, footer: Text("This key type is created according to BIP-340 and is suitable for all types of signatures and script pubkeys, including Schnorr signatures and Taproot v1 witness. It also can be used with all other descriptors and ECDSA")) {
                }
                
                Section(header: VStack(alignment: .leading) {
                    Text("Select key structure:")
                        .padding(.top, 20)
                    Picker(selection: $keyStructure, label: EmptyView()) {
                        Text("Extended master key").tag(KeyStructure.extended)
                        Text("Standalone key").tag(KeyStructure.single)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }, footer: Text("Hierarchically-derived set of keys rooting in the master extended private key. Uses seed phrase for master extended private key backup")) {
                }
            }
            .navigationTitle("New master keypair")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
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
}

struct AddKeyringSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddKeyringSheet()
    }
}
