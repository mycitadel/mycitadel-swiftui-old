//
//  AppView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

enum Sheet {
    case addAccount
    case addKeyring
    case importAsset
    case importAnything
}

struct AppView: View {
    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    #endif
    private var isEditing: Bool {
        #if !os(macOS)
        return editMode?.wrappedValue == .active
        #else
        return false
        #endif
    }

    @StateObject private var citadel = CitadelVault.embedded
    @State private var selection: String? = nil
    @State private var showingSheet = false
    @State private var activeSheet = Sheet.addAccount
    @State private var errorSheet = ErrorSheetConfig()

    var body: some View {
        List(selection: isEditing ? nil : $selection) {
            Section(header: Text("Contracts")) {
                ForEach(citadel.contracts, id: \.id) { contract in
                    NavigationLink(destination: MasterView(wallet: contract)) {
                        Label(contract.name,  systemImage: contract.imageName)
                    }
                    .tag(contract.id)
                }
                /*
                .onMove(perform: { indices, newOffset in
                    accounts.move(fromOffsets: indices, toOffset: newOffset)
                })
                 */
                .onDelete(perform: { indexSet in
                    // TODO: Do the actual removal
                })
                
                if isEditing {
                    Label { Text("Create account") } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }.onTapGesture(perform: createWallet)
                }
            }

            /*
            Section(header: Text("Identities")) {
                ForEach(data.keyrings) { keyring in
                    Label(keyring.name,  systemImage: "signature")
                        .tag(Tags.Keyring(keyring.id))
                }
                .onMove(perform: { indices, newOffset in
                    data.wallets.move(fromOffsets: indices, toOffset: newOffset)
                })
                .onDelete(perform: { indexSet in
                    data.wallets.remove(atOffsets: indexSet)
                })
                
                if isEditing {
                    Label { Text("Create signing key") } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }.onTapGesture(perform: createKeyring)
                }
            }
            */

            Section(header: Text("Main assets")) {
                ForEach(Array(citadel.assets.values), id: \.id) { asset in
                    AssetRow(asset: asset)
                }
                .onDelete(perform: deleteAsset)

                if isEditing {
                    Label { Text("Synchronize") } icon: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.blue)
                    }.onTapGesture(perform: reloadAssets)

                    Label { Text("Import") } icon: {
                        Image(systemName: "square.and.arrow.down.fill")
                            .foregroundColor(.blue)
                    }.onTapGesture(perform: importAsset)
                }
            }

            NavigationLink(destination: AssetsView()) {
                Text("All known assets")
                    .font(.headline)
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


            ToolbarItemGroup(placement: .navigationBarLeading) {
                /*
                Menu {
                    Section {
                        Button("Add account", action: createWallet)
                        Button("Import account", action: {})
                    }

                    Section {
                        Button("New signing key", action: createKeyring)
                        Button("Import keys", action: {})

                    }
                    
                    Section {
                        Button("Sync assets", action: {})
                        Button("Import asset", action: importAsset)
                    }
                } label: {
                    Image(systemName: "plus")
                }
                */
                
                Button(action: createWallet) {
                    Image(systemName: "plus")
                }
                Button(action: importAnything) {
                    Image(systemName: "qrcode.viewfinder")
                }
            }
        })
        .sheet(isPresented: $showingSheet, onDismiss: reloadData, content: sheetContent)
        .alert(isPresented: $errorSheet.presented, content: errorSheet.content)
        .onAppear(perform: reloadData)
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        switch activeSheet {
        case .addAccount: SelectContract()
        case .addKeyring: AddKeyringSheet()
        case .importAsset: Import(importName: "asset", category: .genesis)
        case .importAnything: Import(importName: "anything", category: .all)
        }
    }

    private func reloadData() {
        do {
            try citadel.syncAll()
        } catch {
            errorSheet.present(error)
        }
        do {
            let _ = try citadel.syncAssets()
        } catch {
            errorSheet.present(error)
        }
    }
    
    private func reloadAssets() {
        do {
            let _ = try CitadelVault.embedded.syncAssets()
        } catch {
            errorSheet.present(error)
        }
    }

    private func createWallet() {
        activeSheet = .addAccount
        showingSheet = true
    }

    private func createKeyring() {
        activeSheet = .addKeyring
        showingSheet = true
    }

    private func importAsset() {
        activeSheet = .importAsset
        showingSheet = true
    }
    
    private func importAnything() {
        activeSheet = .importAnything
        showingSheet = true
    }
    
    private func deleteAsset(indexSet: IndexSet) {
        reloadAssets()
    }
}

struct AppView_Previews: PreviewProvider {
    #if !os(macOS)
    @State static var editMode = EditMode.active
    #endif
    
    static var previews: some View {
        Group {
            NavigationView {
                AppView()
                    .previewDevice("iPhone 12 Pro")
            }
            #if !os(macOS)
            NavigationView {
                AppView()
                    .preferredColorScheme(.dark)
                    .environment(\.editMode, $editMode)
                    .previewDevice("iPhone 12 Pro")
            }
            #endif
        }
    }
}
