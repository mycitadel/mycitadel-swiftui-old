//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AssetsSheet: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("Content")
                .navigationTitle("Assets")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Close")
                        }
                    }
                }
        }
    }
}

struct AssetsSheet_Previews: PreviewProvider {
    static var previews: some View {
        AssetsSheet()
    }
}
