//
//  AssetView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI

struct AssetView: View {
    let assetId: String

    var body: some View {
        Text("Hello, World!")
    }
}

struct AssetView_Previews: PreviewProvider {
    static var previews: some View {
        AssetView(assetId: "BTC")
    }
}
