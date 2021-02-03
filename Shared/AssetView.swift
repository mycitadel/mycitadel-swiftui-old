//
//  AssetView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI
import MyCitadelKit

struct AssetView: View {
    let asset: AssetDisplayInfo

    var body: some View {
        List {
            AssetCard(asset: asset)
            
            Section(header: Text("General information")) {
                DetailsCell(title: "Ticker", details: asset.ticker)
                DetailsCell(title: "Name", details: asset.name)
                DetailsCell(title: "Precision", details: "\(asset.precision)")
            }
        }
        .listStyle(GroupedListStyle())
            .navigationTitle("Asset information")
    }
}

struct DetailsCell: View {
    @State var title: String
    @State var details: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(details)
                .font(.title3)
        }
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AssetView(asset: DumbData.init().data.assets[0])
        }
    }
}
