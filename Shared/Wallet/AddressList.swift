//
//  AddressList.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/5/21.
//

import SwiftUI
import CitadelKit

struct AddressList: View {
    @State var wallet: WalletContract

    var body: some View {
        List {
            ForEach(wallet.usedAddresses) { addressDerivation in
                NavigationLink(destination: AddressView(wallet: wallet, addressDerivation: addressDerivation)) {
                    BechBrief(text: addressDerivation.address)
                }
            }
        }
        .navigationTitle("Address list")
    }
}

struct AddressList_Previews: PreviewProvider {
    static var previews: some View {
        AddressList(wallet: CitadelVault.embedded.contracts.first!)
    }
}
