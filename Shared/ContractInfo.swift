//
//  ContractInfo.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI
import MyCitadelKit

struct ContractInfo: View {
    var wallet: WalletContract
    
    var body: some View {
        EmptyView()
    }
}

struct ContractInfo_Previews: PreviewProvider {
    static var previews: some View {
        ContractInfo(wallet: CitadelVault.embedded.contracts.first!)
    }
}
