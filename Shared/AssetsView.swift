//
//  AssetsList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI
import MyCitadelKit

struct AssetsView: View {
    @State private var filterClass: Int = 0
    @State private var filterBalance: Int = 0
    @State private var sortField: Int = 0
    @State private var sortOrder: Int = 0

    private var assetList: AssetList {
        AssetList(showingSheet: $showingImportSheet, errorSheet: $errorSheet)
    }

    @State private var showingImportSheet: Bool = false
    @State private var errorSheet = ErrorSheetConfig()

    var body: some View {
        self.assetList
        .navigationTitle("Known assets")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()

                Menu {
                    Picker(selection: $filterClass, label: Text("Asset class")) {
                        Text("All asset classes").tag(0)
                        Text("Fungible assets").tag(1)
                        Text("Non-fungible tokens").tag(2)
                    }

                    Picker(selection: $filterBalance, label: Text("Asset class")) {
                        Text("All known assets").tag(3)
                        Text("With positive balance").tag(4)
                        Text("With zero balance").tag(5)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                Spacer()

                Menu {
                    Picker(selection: $sortField, label: Text("Sort by")) {
                        Text("Ticker").tag(0)
                        Text("Name").tag(1)
                        Text("Asset amount").tag(2)
                        Text("Asset value").tag(3)
                        Text("Asset price").tag(4)
                    }

                    Picker(selection: $sortOrder, label: Text("Sorting order")) {
                        Text("Ascending").tag(5)
                        Text("Descending").tag(6)
                    }
                } label: {
                    Image(systemName: "line.horizontal.3.decrease")
                }
            
                Spacer()

                Button(action: reloadAssets) {
                    Image(systemName: "arrow.clockwise")
                }

                Spacer()

                Button(action: importAsset) {
                    Image(systemName: "square.and.arrow.down")
                }

                Spacer()
            }

            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
        .alert(isPresented: $errorSheet.presented, content: errorSheet.content)
        .sheet(isPresented: $showingImportSheet) {
            Import(importName: "asset", category: .genesis).onDisappear(perform: self.reloadAssets)
        }
    }

    private func reloadAssets() {
        assetList.reloadAssets()
    }
    
    private func importAsset() {
        showingImportSheet = true
    }
}

struct AssetList: View {
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

    @Binding var showingSheet: Bool
    @Binding var errorSheet: ErrorSheetConfig

    var body: some View {
        List {
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
        .onAppear(perform: reloadAssets)
    }
    
    public func reloadAssets() {
        do {
            let _ = try CitadelVault.embedded.syncAssets()
        } catch {
            errorSheet.present(error)
        }
    }
    
    public func importAsset() {
        showingSheet = true
    }

    private func deleteAsset(indexSet: IndexSet) {
        reloadAssets()
    }
}

struct AssetRow: View {
    var asset: Asset
    
    var body: some View {
        NavigationLink(destination: AssetView(asset: asset)) {
            HStack {
                Label(asset.name, systemImage: asset.symbol)
                Spacer()
                Text(asset.ticker)
            }
        }
        .tag(Tags.Asset(asset.id))
    }
}

struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AssetsView()
        }
    }
}
