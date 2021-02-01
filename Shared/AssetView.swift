//
//  AssetView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/1/21.
//

import SwiftUI

struct AssetView: View {
    @Binding var asset: AssetDisplayInfo

    var body: some View {
        Text("Hello, World!")
    }
}

struct AssetView_Previews: PreviewProvider {
    @State static var dumbData = DumbData().data.assets.first!

    static var previews: some View {
        AssetView(asset: $dumbData)
    }
}
