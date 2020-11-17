//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AddAccountSheet: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        NavigationView {
            Text("Content")
                .navigationTitle("New account")
                .toolbar(content: {
                    Button(action: {
                        self.showSheet = false
                    }) {
                        Text("Create").bold()
                    }}
                )
        }
    }
}

struct AddAccount_Previews: PreviewProvider {
    @State static var display = true

    static var previews: some View {
        AddAccountSheet(showSheet: $display)
    }
}
