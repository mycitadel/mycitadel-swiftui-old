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

    @State private var navigateResult: Bool? = nil
    @State private var transfer: PaymentResult? = nil
    @State private var errorMessage: String? = nil
    @State private var updatedAmount: String

    @State var wallet: WalletContract?
    @State var invoice: Invoice
    @State var invoiceString: String

    private var amountString: String {
        String(invoice.amount ?? 0)
    }
    var verificationStatus: VerificationStatus = .unverified
    var hasAmount: Bool {
        invoice.amountString != "any"
    }
    var nonZeroAmount: Bool {
        Double(updatedAmount) ?? 0 > 0
    }
    var rgbAsset: RGB20Asset? {
        invoice.asset as? RGB20Asset
    }

    init(wallet: WalletContract? = nil, invoice: Invoice, invoiceString: String) {
        _updatedAmount = .init(initialValue: String(invoice.amount ?? 0))
        _wallet = .init(initialValue: wallet)
        _invoice = .init(initialValue: invoice)
        _invoiceString = .init(initialValue: invoiceString)
    }
    
    var body: some View {
        Form {
            if let transfer = transfer {
                NavigationLink("Payment result", destination: PayslipView(txid: transfer.txid, consignment: transfer.consignment), tag: true, selection: $navigateResult)
            }
            
            Section(header: Text("Amount")) {
                HStack {
                    AmountField(
                        placeholder: "Specify amount",
                        units: .accounting,
                        amount: $updatedAmount
                    )
                    .font(.largeTitle)
                    .disabled(hasAmount)
                    Text(invoice.asset?.ticker ?? CitadelVault.embedded.network.ticker())
                }
                if let rgbAsset = rgbAsset {
                    VStack(alignment: .leading) {
                        Text(rgbAsset.name)
                        Text(rgbAsset.id)
                    }
                }
            }
            
            // TODO: Add fees

            Section(
                header: Text("To"),
                footer: HStack {
                    Spacer()
                    Label(
                        verificationStatus.localizedString,
                        systemImage: verificationStatus.verifiedSymbol
                    )
                    .foregroundColor(verificationStatus.verifiedColor)
                }
            ) {
                if let merchant = invoice.merchant {
                    Text(merchant)
                        .font(.title)
                }
                Text(invoice.beneficiary)
                    .font(.subheadline)
            }
            
            if let purpose = invoice.purpose {
                Section(header: Text("For")) {
                    Text(purpose)
                }
            }
            
            Section(header: Text("From")) {
                ForEach(CitadelVault.embedded.contracts, id: \.id) { contract in
                    Button(action: { wallet = contract }) {
                        Label {
                            Text(contract.name)
                        } icon: {
                            Image(systemName: "checkmark").opacity(wallet?.id == contract.id ? 1 : 0)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }

            if let errorMessage = errorMessage {
                Section(footer: Text(errorMessage).foregroundColor(.red).italic().padding(.bottom)) {}
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
                    .background(nonZeroAmount ? Color.purple : Color.gray)
                    .cornerRadius(13)
                    .disabled(!nonZeroAmount)
                }
                .font(.title3)
            ) {}

            Section(header:
                Button(action: dissmiss) {
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
            
            // TODO: Add "pay later" function
        }
        .navigationTitle("Pay")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Pay", action: pay)
            }
        }
    }
    
    private func pay() {
        guard let wallet = wallet else {
            errorMessage = "You need to select contract to pay from"
            return
        }
        do {
            invoice.amountString = updatedAmount
            errorMessage = nil
            transfer = try wallet.pay(invoice: invoiceString, fee: 1000)
            navigateResult = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(wallet: CitadelVault.embedded.contracts.first!, invoice: Invoice(beneficiary: ""), invoiceString: "")
    }
}
