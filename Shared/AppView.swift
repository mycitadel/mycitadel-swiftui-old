//
//  AppView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AppView: View {
    enum Selection: Hashable {
        case Account(UUID)
        case Keyring(UUID)
        case Asset(String)
        case Settings
    }
    
    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    #endif
    @State private var showingCreateAccount = false
    @State private var selection: Selection? = nil
    @Binding var data: AppDisplayInfo
    
    private var isEditing: Bool {
        #if !os(macOS)
        return editMode?.wrappedValue == .active
        #else
        return false
        #endif
    }
    
    func createWallet() {}
    func createKeyring() {}

    var body: some View {
        List(selection: isEditing ? nil : $selection) {
            Section(header: Text("Accounts")) {
                ForEach(data.wallets.indices) { idx in
                    NavigationLink(destination: MasterView(wallet: $data.wallets[idx])) {
                        Label(data.wallets[idx].name,  systemImage: "creditcard.fill")
                    }
                    .tag(Selection.Account(data.wallets[idx].id))
                }
                .onMove(perform: { indices, newOffset in
                    data.wallets.move(fromOffsets: indices, toOffset: newOffset)
                })
                .onDelete(perform: { indexSet in
                    data.wallets.remove(atOffsets: indexSet)
                })
                
                if isEditing {
                    Label { Text("Add") } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }

            Section(header: Text("Signing keys")) {
                ForEach(data.keyrings) { keyring in
                    Label(keyring.name,  systemImage: "signature")
                        .tag(Selection.Keyring(keyring.id))
                }

                .onMove(perform: { indices, newOffset in
                    data.wallets.move(fromOffsets: indices, toOffset: newOffset)
                })
                .onDelete(perform: { indexSet in
                    data.wallets.remove(atOffsets: indexSet)
                })
                
                if isEditing {
                    Label { Text("Add") } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }

            Section(header: Text("Assets")) {
                ForEach(data.assets, id: \.ticker) { asset in
                    HStack {
                        Label(asset.name, systemImage: asset.symbol)
                        Spacer()
                        Text(asset.ticker)
                    }
                    .tag(Selection.Asset(asset.ticker))
                }

                if isEditing {
                    Label { Text("Synchronize") } icon: {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("My Citadel")
        .frame(minWidth: 150, idealWidth: 250, maxWidth: 400)
        .toolbar(content: {
            #if os(macOS)
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
            #endif


            ToolbarItem(placement: .cancellationAction) {
                Menu {
                    Section {
                        Button("Add account", action: createWallet)
                        Button("Import account", action: createKeyring)
                        Button("Export account", action: createKeyring)
                    }

                    Section {
                        Button("New signing key", action: createKeyring)
                        Button("Import keys", action: createKeyring)
                        Button("Export keys", action: createKeyring)

                    }
                    
                    Section {
                        Button("Sync assets", action: createKeyring)
                        Button("Import assets", action: createKeyring)
                        Button("Export assets", action: createKeyring)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        })
    }
}

struct AppView_Previews: PreviewProvider {
    @State static var dumb_data = DumbData().data
    
    static var previews: some View {
        AppView(data: $dumb_data)
            //.preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
