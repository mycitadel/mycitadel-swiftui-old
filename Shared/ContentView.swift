//
//  ContentView.swift
//  Shared
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct ContentView: View {
    @Binding var data: AppDisplayInfo
    @State private var selection: String = ""

    var body: some View {
        NavigationView {
            AppView(data: $data)
            
            MasterView(wallet: $data.wallets[0])
            TransactionView(wallet: data.wallets[0])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var dumb = DumbData()

    static var previews: some View {
        Group {
            ContentView(data: $dumb.data)
                .previewDevice("iPhone 12 Pro")

            ContentView(data: $dumb.data)
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 2388/2, height: 1668/2))
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
        }
    }
}
