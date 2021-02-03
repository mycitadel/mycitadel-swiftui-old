//
//  SheetConfig.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/3/21.
//

import SwiftUI

class SheetConfig: ObservableObject {
    var presented: Bool = false
    
    func present() {
        self.presented = true
    }
}

class ErrorSheetConfig: SheetConfig {
    var title: String = "Error"
    var message: String

    override init() {
        self.message = ""
    }

    var content: () -> Alert {
        { () -> Alert in
            Alert(title: Text(self.title), message: Text(self.message), dismissButton: .cancel())
        }
    }
    
    func present(_ error: Error) {
        message = error.localizedDescription
        super.present()
    }
}
