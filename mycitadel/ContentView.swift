//
//  ContentView.swift
//  mycitadel
//
//  Created by Maxim Orlovsky on 12-01-2020.
//  Copyright © 2020 Datagnition. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    static let Tab1Title = "Assets & Balances"
    static let Tab2Title = "Send & Receive"

    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            NavigationView {
                AssetsView(assets.map {
                    AssetCard(asset: $0, brief: false)
                        .frame(minWidth: 113, idealWidth: 266, maxWidth: 331, minHeight: 131, idealHeight: 166, maxHeight: 213)
                        .padding()
                })
                .navigationBarTitle(Self.Tab1Title)
            }
            .tabItem {
                VStack {
                    Image(systemName: "bitcoinsign.circle" + (selection == 0 ? ".fill" : "")).font(.title)
                    Text(Self.Tab1Title)
                }
            }
            .tag(0)
            TransferView(assets.map {
                AssetCard(asset: $0, brief: true)
                    .frame(minWidth: 113, idealWidth: 266, maxWidth: 331, minHeight: 66, idealHeight: 113, maxHeight: 213)
                    .padding()
            })
            .tabItem {
                VStack {
                    Image(systemName: "arrow.up.arrow.down.circle" + (selection == 1 ? ".fill" : "")).font(.title)
                    Text(Self.Tab2Title)
                }
            }
            .tag(1)
        }.accentColor(.purple)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           ContentView()
              .environment(\.colorScheme, .light)

           ContentView()
              .environment(\.colorScheme, .dark)
        }
    }
}
