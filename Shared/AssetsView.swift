//
//  AssetsList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI
import MyCitadelKit

struct AssetsView: View {
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

    @State private var assets: [AssetDisplayInfo] = []
    @State private var filterClass: Int = 0
    @State private var filterBalance: Int = 0
    @State private var sortField: Int = 0
    @State private var sortOrder: Int = 0
    @State private var showingSheet: Bool = false
    @State private var errorSheet: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        List {
            ForEach(assets.indices) { idx in
                NavigationLink(destination: AssetView(asset: $assets[idx])) {
                    HStack {
                        Label(assets[idx].name, systemImage: assets[idx].symbol)
                        Spacer()
                        Text(assets[idx].ticker)
                    }
                }
                .tag(Tags.Asset(assets[idx].ticker))
            }
            .onDelete(perform: { indexSet in
                assets.remove(atOffsets: indexSet)
            })

            if isEditing {
                Label { Text("Synchronize") } icon: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.blue)
                }.onTapGesture(perform: assetsSync)

                Label { Text("Import") } icon: {
                    Image(systemName: "square.and.arrow.down.fill")
                        .foregroundColor(.blue)
                }.onTapGesture(perform: importAsset)
            }
        }
        .navigationTitle("Known Assets")
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
                        Text("All known assets").tag(0)
                        Text("With positive balance").tag(1)
                        Text("With zero balance").tag(2)
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
                        Text("Ascending").tag(0)
                        Text("Descending").tag(1)
                    }
                } label: {
                    Image(systemName: "line.horizontal.3.decrease")
                }
            
                Spacer()

                Button(action: assetsSync) {
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
        .sheet(isPresented: $showingSheet) {
            Import(importName: "asset", category: .genesis).onDisappear(perform: assetsSync)
        }
        .alert(isPresented: $errorSheet, content: {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        })
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        assetsSync()
    }
    
    private func importAsset() {
        self.showingSheet = true
    }
    
    private func assetsSync() {
        do {
            assets = try MyCitadelClient.shared?.refreshAssets().map(AssetDisplayInfo.init) ?? []
        } catch {
            errorSheet = true
            errorMessage = error.localizedDescription
        }
    }
}

struct AssetsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView()
    }
}
