//
//  Controls.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI
import Combine

struct AmountField: View {
    let placeholder: String
    let units: Units
    @Binding var amount: String
    
    var body: some View {
        TextField(placeholder, text: $amount)
            .multilineTextAlignment(.trailing)
            .conditional {
                #if os(iOS)
                return AnyView($0.keyboardType(units == .atomic ? .numberPad : .decimalPad))
                #else
                    return AnyView($0)
                #endif
            }
            .onReceive(Just(amount)) { newValue in
                let filtered = newValue.filter { "0123456789.,".contains($0) }
                if filtered != newValue {
                    amount = filtered
                }
                if units == .atomic {
                    let amount = "\(UInt64(self.amount) ?? 0)"
                    if amount != self.amount {
                        self.amount = amount
                    }
                } else {
                    let amount = "\(Double(self.amount) ?? 0)"
                    if amount != self.amount {
                        self.amount = amount
                    }
                }
            }
    }
}

struct Controls_Previews: PreviewProvider {
    @State static var amount: String = ""
    static var previews: some View {
        AmountField(placeholder: "Amount", units: .accounting, amount: $amount)
    }
}
