//
//  PaymentView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI
import MyCitadelKit

struct PaymentView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var amount: String = ""
    @State private var navigateResult: Bool = false
    @State private var transfer: PaymentResult? = nil
    @State private var errorMessage: String? = nil

    var wallet: WalletContract
    var invoice: Invoice
    var invoiceString: String
    var hasAmount: Bool {
        Double(amount) ?? 0 != 0
    }


    var body: some View {
        NavigationView {
            Form {
                AmountField(
                    placeholder: "Specify amount",
                    units: .accounting,
                    amount: $amount
                )
                .font(.largeTitle)
                .disabled(invoice.amount != nil)

                Section(header: Text("To")) {
                    if let merchant = invoice.merchant {
                        Text(merchant)
                            .font(.title)
                    }
                    Text(invoice.beneficiary)
                        .font(.subheadline)
                }
                
                Section(header:
                    Button(action: pay) {
                        HStack {
                            Spacer()
                            Text("Pay")
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(hasAmount ? Color.purple : Color.gray)
                        .cornerRadius(13)
                        .disabled(!hasAmount)
                    }
                    .font(.title3)
                ) {}
                
                Section(header:
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Cancel")
                            Spacer()
                        }
                        .padding()
                        .cornerRadius(13)
                    }
                    .font(.title3)
                ) {}
                
                if let errorMessage = errorMessage {
                    Section(footer: Text(errorMessage).foregroundColor(.red)) {
                    }
                }
            }
            .navigationTitle("Pay")
        }
        .onAppear {
            amount = invoice.amount != nil ? "\(invoice.amount!)" : ""
        }
    }
    
    func pay() {
        do {
            errorMessage = nil
            transfer = try wallet.pay(invoice: invoiceString, fee: 1000)
            navigateResult = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(wallet: CitadelVault.embedded.contracts.first!, invoice: Invoice(beneficiary: ""), invoiceString: "")
    }
}
