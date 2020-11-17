//
//  AddAccount.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI

struct AddKeyringSheet: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("Content")
                .navigationTitle("New signing key")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Create").bold()
                        }
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

struct AddKeyringSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddKeyringSheet()
    }
}
