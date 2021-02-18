//
//  SwiftUIView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/4/21.
//

import SwiftUI

struct CreateSigner: View {
    @Environment(\.presentationMode) var presentationMode

    @State var masterKey: String = "recent"
    @State private var useAdvanced = false
    @State private var customDerivation = false
    @State private var signerName: String = ""
    @State private var coinSegment: UInt32 = 84
    @State private var changeIndex: UInt32 = 84
    @State private var changeHardened = false

    var body: some View {
        Form {
            Section(footer: HStack {
                Spacer()
                Text("[78cd]/88'/1'/0/0/5-87782").fontWeight(.bold)
            }) {
                TextField("Signer role name", text: $signerName)
                Picker(selection: $masterKey, label: Text("Master extended key")) {
                    Group {
                        Text("just created").tag("recent")
                    }// .navigationTitle("Select master key")
                }
                Toggle("Advanced configuration", isOn: $useAdvanced)
            }
            
            if useAdvanced {
                Section(header: VStack(alignment: .leading) {
                    Picker(selection: $customDerivation, label: EmptyView()) {
                        Text("Constructor").tag(false)
                        Text("Manual").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }.padding(.top, 20)) {
                }
            
                Section(header: VStack(alignment: .leading) {
                    Text("Purpose part:")
                    Picker(selection: $customDerivation, label: EmptyView()) {
                        Text("Standard").tag(false)
                        Text("Custom").tag(true)
                        Text("None").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }) {
                    Text("Taproot") // 340?
                    Text("SegWit") // 84
                    Text("Pre-SegWit single-sig") // 44
                    Text("Pre-SegWit multisig / scripted") // 49
                }
                
                
                Section(header: VStack(alignment: .leading) {
                    Text("Asset part:")
                    Picker(selection: $customDerivation, label: EmptyView()) {
                        Text("Standard").tag(false)
                        Text("Custom").tag(true)
                        Text("None").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }) {
                    Text("RGB-enabled") // 827166'
                    Text("Bitcoin") // 0' and 1' for testnet
                    Text("Liquid") // 1776
                }

                Section(header: VStack(alignment: .leading) {
                    Text("Account part:")
                    Picker(selection: $customDerivation, label: EmptyView()) {
                        Text("Custom").tag(true)
                        Text("None").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }) {
                    HStack {
                        Stepper("Index", value: $changeIndex)
                        Text("\(changeIndex)").padding(.leading, 13)
                    }
                    Toggle("Hardened", isOn: $changeHardened)
                }

                Section(header: VStack(alignment: .leading) {
                    Text("Change part:")
                    Picker(selection: $customDerivation, label: EmptyView()) {
                        Text("Normal").tag(false)
                        Text("Change").tag(true)
                        Text("Custom").tag(true)
                        Text("None").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }) {
                    HStack {
                        Stepper("Index", value: $changeIndex)
                        Text("\(changeIndex)").padding(.leading, 13)
                    }
                    Toggle("Hardened", isOn: $changeHardened)
                }

                Section(header: VStack(alignment: .leading) {
                    Text("Index part:")
                    Picker(selection: $customDerivation, label: EmptyView()) {
                        Text("Wildcard").tag(false)
                        Text("Ranged").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }) {
                    HStack {
                        Stepper("From", value: $changeIndex)
                        Text("\(changeIndex)").padding(.leading, 13)
                    }
                    HStack {
                        Stepper("To", value: $changeIndex)
                        Text("\(changeIndex)").padding(.leading, 13)
                    }
                    Toggle("Hardened", isOn: $changeHardened)
                }
            }
        }
        .navigationTitle("Create signer role")
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

struct CreateSigner_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateSigner()
        }
    }
}
