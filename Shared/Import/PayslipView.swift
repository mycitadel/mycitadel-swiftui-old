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
            Button(action: {
                #if os(iOS)
                    UIPasteboard.general.string = txid
                #endif
                #if os(macOS)
                    NSPasteboard.general.setString(txid, forType: .string)
                #endif
            }) {
                HStack {
                    Text(txid)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "doc.on.doc")
                }
            }
                        
            if let consignment = consignment {
                Button(action: {
                    #if os(iOS)
                        UIPasteboard.general.string = consignment
                    #endif
                    #if os(macOS)
                        NSPasteboard.general.setString(consignment, forType: .string)
                    #endif
                }) {
                    HStack {
                        Text(consignment)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "doc.on.doc")
                    }
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
