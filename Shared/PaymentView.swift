//
//  PaymentView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI
import MyCitadelKit

struct PaymentView: View {
    var invoice: Invoice
    
    @State private var amount: String = ""
    
    var body: some View {
        Form {
            AmountField(
                placeholder: "Specify amount",
                units: .accounting,
                amount: $amount
            )
                .font(.largeTitle)
        }
        .navigationTitle("Pay")
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(invoice: Invoice(beneficiary: ""))
    }
}
