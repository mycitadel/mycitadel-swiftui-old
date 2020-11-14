//
//  TransferView.swift
//  mycitadel
//
//  Created by Maxim Orlovsky on 16-01-2020.
//  Copyright © 2020 Datagnition. All rights reserved.
//

import SwiftUI

struct TransferView<Card: View>: View {
    var viewControllers: [UIHostingController<Card>]
    @State var currentPage = 0
        
    init(_ views: [Card]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        VStack {
            Spacer()
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
                .frame(height: 113)
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
                .padding(0).frame(height: 13)
            Spacer()
            Text("10 435 646").font(.system(size: 66.6)).scaledToFit()
            DialView().padding(.horizontal)
            Divider()
            Spacer()
            HStack {
                Spacer()
                Button(action: { () }) {
                    Text("Send").font(.title)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.accentColor)
                        .cornerRadius(13)
                }
                Spacer()
                Button(action: { () }) {
                    Text("Request").font(.title)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.accentColor)
                        .cornerRadius(13)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct TransferView_Previews: PreviewProvider {
    static var previews: some View {
        TransferView(assets.map { AssetCard(asset: $0, brief: true)
            .frame(minWidth: 113, idealWidth: 266, maxWidth: 331, minHeight: 66, idealHeight: 113, maxHeight: 213)
            .padding() })
    }
}

struct DialView: View {
    var body: some View {
        HStack() {
            VStack {
                Button(action: { () }) { Text("1") }.padding(.vertical)
                Button(action: { () }) { Text("4") }.padding(.vertical)
                Button(action: { () }) { Text("7") }.padding(.vertical)
                Button(action: { () }) { Text("000") }.padding(.vertical)
            }
            Spacer()
            VStack {
                Button(action: { () }) { Text("2") }.padding(.vertical)
                Button(action: { () }) { Text("5") }.padding(.vertical)
                Button(action: { () }) { Text("8") }.padding(.vertical)
                Button(action: { () }) { Text("0") }.padding(.vertical)
            }
            Spacer()
            VStack {
                Button(action: { () }) { Text("3") }.padding(.vertical)
                Button(action: { () }) { Text("6") }.padding(.vertical)
                Button(action: { () }) { Text("9") }.padding(.vertical)
                Button(action: { () }) { Image(systemName: "delete.left").padding(.bottom) }.padding(.vertical)
            }
        }
        .font(.title)
        .padding(.horizontal)
        .aspectRatio(contentMode: .fill)
    }
}
