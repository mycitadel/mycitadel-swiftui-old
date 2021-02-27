//
//  ContentView.swift
//  Shared
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            AppView()
            
            MasterView(wallet: CitadelVault.embedded.contracts.first!)
            TransactionView(wallet: CitadelVault.embedded.contracts.first!)
                .navigationTitle("History")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone 12 Pro")

            ContentView()
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 2388/2, height: 1668/2))
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
        }
    }
}
