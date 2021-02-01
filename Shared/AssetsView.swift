//
//  AssetsList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI

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

    @Binding var assets: [AssetDisplayInfo]

    var body: some View {
        List {
            AssetsList(assets: $assets)
        }
        .navigationTitle("Known Assets")
        .toolbar {
            ToolbarItem {
                Button(action: importAsset, label: {
                    Image("square.and.arrow.down")
                })
            }
            ToolbarItem {
                EditButton()
            }
        }
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
    }
    
    private func importAsset() {
        
    }
}

struct AssetsList: View {
    @Binding var assets: [AssetDisplayInfo]

    var body: some View {
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
    }
}

struct AssetsView_Previews: PreviewProvider {
    @State static var dumbData = DumbData().data.assets

    static var previews: some View {
        AssetsView(assets: $dumbData)
    }
}
