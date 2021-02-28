//
//  AppView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AppView: View {
    enum Selection: Hashable {
        case Account(UUID)
        case Keyring(UUID)
        case Asset(String)
        case Settings
    }
    
    @State private var showingCreateAccount = false
    @State private var isKeysExpanded = true
    @State private var isAssetsExpanded = true
    @State private var selection: Selection? = nil
    @Binding var data: AppDisplayInfo
    
    func createWallet() {}
    
    var body: some View {
        List(selection: $selection) {
            HStack {
                Label("Accounts", systemImage: "creditcard.fill")
                    .onTapGesture { }
                #if !os(macOS)
                Spacer()
                Button(action: { showingCreateAccount = true }) {
                    Image(systemName: "plus.circle")
                }
                .foregroundColor(.accentColor)
                .sheet(isPresented: $showingCreateAccount, content: {
                    AddAccountSheet(showSheet: $showingCreateAccount)
                })
                #endif
            }
            .font(.title2)
            ForEach(data.wallets.indices) { idx in
                NavigationLink(destination: MasterView(wallet: $data.wallets[idx])) {
                    HStack {
                        Text(data.wallets[idx].name)
                        Spacer()
                        Text("\(data.wallets[idx].assets.count) assets")
                            .font(.footnote)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(13)

                    }
                }
                .tag(Selection.Account(data.wallets[idx].id))
                .padding(.leading)
            }
            //Divider()

            DisclosureGroup(
                isExpanded: $isKeysExpanded,
                content: {
                    ForEach(data.keyrings) { keyring in
                        Text(keyring.name)
                            .tag(Selection.Keyring(keyring.id))
                    }
                },
                label: {
                    HStack {
                        Label("Signing keys", systemImage: "signature")
                            .onTapGesture {
                                withAnimation {
                                    isKeysExpanded.toggle()
                                }
                            }
                        Spacer()
                        Button(action: { showingCreateAccount = true }) {
                            Image(systemName: "plus.circle")
                        }
                        .padding(.trailing, 13)
                        .foregroundColor(.accentColor)
                        .sheet(isPresented: $showingCreateAccount, content: {
                            AddAccountSheet(showSheet: $showingCreateAccount)
                        })
                    }
                    .font(.title2)
                }
            )
            //Divider()

            DisclosureGroup(
                isExpanded: $isAssetsExpanded,
                content: {
                    ForEach(data.assets, id: \.ticker) { asset in
                        HStack {
                            Image(systemName: asset.symbol)
                            Text(asset.name)
                            Spacer()
                            Text(asset.ticker)
                        }
                        .tag(Selection.Asset(asset.ticker))
                    }
                },
                label: {
                    HStack {
                        Label("Assets", systemImage: "scroll")
                            .onTapGesture {
                                withAnimation {
                                    isAssetsExpanded.toggle()
                                }
                            }
                        Spacer()
                        Button(action: { showingCreateAccount = true }) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }
                        .padding(.trailing, 13)
                        .foregroundColor(.accentColor)
                        .sheet(isPresented: $showingCreateAccount, content: {
                            AddAccountSheet(showSheet: $showingCreateAccount)
                        })
                    }
                    .font(.title2)
                }
            )
            //Divider()

            Label("Settings", systemImage: "gear")
                .font(.title2)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("My Citadel")
        .frame(minWidth: 150, idealWidth: 250, maxWidth: 400)
    }
}

struct AppView_Previews: PreviewProvider {
    @State static var dumb_data = DumbData().data
    
    static var previews: some View {
        AppView(data: $dumb_data)
            //.preferredColorScheme(.dark)
            .previewDevice("iPhone 12 Pro")
    }
}
