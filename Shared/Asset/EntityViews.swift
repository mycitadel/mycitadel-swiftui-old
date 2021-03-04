//
//  EntityViews.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/24/21.
//

import SwiftUI
import MyCitadelKit

struct AssetAuthenticityImage: View {
    var asset: Asset
    
    var body: some View {
        Image(systemName: asset.authenticity.symbol)
            .foregroundColor(asset.authenticity.color)
    }
}

struct EntityViews_Previews: PreviewProvider {
    static var previews: some View {
        AssetAuthenticityImage(asset: CitadelVault.embedded.assets.values.first!)
    }
}
