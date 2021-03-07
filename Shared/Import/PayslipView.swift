//
//  PaymentResultView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI

struct PayslipView: View {
    let txid: String
    let consignment: String?
    
    var body: some View {
        Form {
            Section(header: Text("Transaction id")) {
                CopyableText(text: txid, copyable: true, useSpacer: true)
            }

            if let consignment = consignment {
                Section(header: Text("Consignment to share")) {
                    CopyableText(text: consignment, copyable: true, useSpacer: true)
                    
                    generateQRCode(from: consignment)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .navigationTitle("Payment created")
    }
}

struct PayslipView_Previews: PreviewProvider {
    static var previews: some View {
        PayslipView(txid: "", consignment: "")
    }
}
