//
//  AppView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

enum Tags: Hashable {
    case Account(UUID)
    case Keyring(UUID)
    case Asset(String)
    case Settings
}

struct AppView: View {
    enum Sheet {
        case addAccount
        case addKeyring
        case importAsset
        case importAnything
    }
    
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

    @State private var showingSheet = false
    @State private var activeSheet = Sheet.addAccount
    @State private var selection: Tags? = nil
    @Binding var data: AppDisplayInfo
    @State private var assets: [AssetDisplayInfo] = []
    
    var body: some View {
        List(selection: isEditing ? nil : $selection) {
            Section(header: Text("Accounts")) {
                ForEach(data.wallets.indices) { idx in
                    NavigationLink(destination: MasterView(wallet: $data.wallets[idx])) {
                        Label(data.wallets[idx].name,  systemImage: data.wallets[idx].imageName)
                    }
                    .tag(Tags.Account(data.wallets[idx].id))
                }
                .onMove(perform: { indices, newOffset in
                    data.wallets.move(fromOffsets: indices, toOffset: newOffset)
                })
                .onDelete(perform: { indexSet in
                    data.wallets.remove(atOffsets: indexSet)
                })
                
                if isEditing {
                    Label { Text("Create account") } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }.onTapGesture { createWallet() }
                }
            }

            Section(header: Text("Signing keys")) {
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
                    }.onTapGesture { createKeyring() }
                }
            }

            Section(header: Text("Assets with balance")) {
                ForEach(data.assets, id: \.ticker) { asset in
                    HStack {
                        Label(asset.name, systemImage: asset.symbol)
                        Spacer()
                        Text(asset.ticker)
                    }
                    .tag(Tags.Asset(asset.ticker))
                }

                if isEditing {
                    Label { Text("Synchronize") } icon: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.blue)
                    }.onTapGesture { importAsset() }
                }
            }

            NavigationLink(destination: AssetsView(assets: $data.assets)) {
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
                    Image(systemName: "ellipsis.circle")
                }
                
                Button(action: importAnything) {
                    Image(systemName: "qrcode.viewfinder")
                }
            }
        })
        .sheet(isPresented: $showingSheet, content: sheetContent)
        .onAppear(perform: load)
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        switch activeSheet {
        case .addAccount: AddAccountSheet(data: $data)
        case .addKeyring: AddKeyringSheet()
        case .importAsset: Import(importName: "asset", category: .genesis)
        case .importAnything: Import(importName: "anything", category: .all)
        }
    }
    
    private func load() {
        let a = try? MyCitadelClient.shared?.refreshAssets().map { asset in
            AssetDisplayInfo(withTicker: asset.ticker, name: asset.name, symbol: "bitcoinsign.circle.fill")
        }
        self.assets = a ?? []
    }

    func createWallet() {
        activeSheet = .addAccount
        showingSheet = true
    }

    func createKeyring() {
        activeSheet = .addKeyring
        showingSheet = true
    }

    func importAsset() {
        activeSheet = .importAsset
        showingSheet = true
    }
    
    func importAnything() {
        activeSheet = .importAnything
        showingSheet = true
    }
}

struct AppView_Previews: PreviewProvider {
    @State static var dumbData = DumbData().data
    #if !os(macOS)
    @State static var editMode = EditMode.active
    #endif
    
    static var previews: some View {
        Group {
            AppView(data: $dumbData)
                .previewDevice("iPhone 12 Pro")
            #if !os(macOS)
            AppView(data: $dumbData)
                .preferredColorScheme(.dark)
                .environment(\.editMode, $editMode)
                .previewDevice("iPhone 12 Pro")
            #endif
        }
    }
}
