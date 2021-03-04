//
//  SheetConfig.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/3/21.
//

import SwiftUI
import MyCitadelKit

enum PresentedSheet {
    case invoice(WalletContract?, String?)
    case scan(String, Import.Category)
    case pay(WalletContract, Invoice)
}

extension PresentedSheet: Identifiable {
    var id: Int {
        switch self {
        case .invoice(_, _): return 0
        case .scan(_, _): return 1
        case .pay(_, _): return 2
        }
    }
}


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
