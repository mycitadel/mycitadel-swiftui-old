//
//  Controls.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/3/21.
//

import SwiftUI
import Combine

func clipboardCopy(text: String) {
    #if os(iOS)
        UIPasteboard.general.string = text
    #endif
    #if os(macOS)
        NSPasteboard.general.setString(text, forType: .string)
    #endif
}

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

struct CopyableText: View {
    @State var text: String
    @State var copyable: Bool = false
    @State var multilineTextAlignment = TextAlignment.leading
    var useSpacer: Bool = false

    var body: some View {
        if copyable {
            Button(action: { My_Citadel.clipboardCopy(text: text) }) {
                HStack {
                    Text(text)
                        .font(.body)
                        .multilineTextAlignment(multilineTextAlignment)
                    if useSpacer {
                        Spacer()
                    }
                    Image(systemName: "doc.on.doc")
                }
            }
            .foregroundColor(.primary)
        } else {
            Text(text)
                .font(.body)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct DetailsCell: View {
    @State var title: String
    @State var details: String
    @State var subdetails: String?
    @State var clipboardCopy: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            VStack(alignment: .trailing) {
                CopyableText(text: details, copyable: clipboardCopy, multilineTextAlignment: .trailing)
                if let subdetails = subdetails {
                    Text(subdetails)
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct SubheadingCell: View {
    @State var title: String
    @State var details: String
    @State var clipboardCopy: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Spacer()
            CopyableText(text: details, copyable: clipboardCopy, useSpacer: true)
        }.padding(.vertical, 6)
    }
}

struct Controls_Previews: PreviewProvider {
    @State static var amount: String = ""
    static var previews: some View {
        AmountField(placeholder: "Amount", units: .accounting, amount: $amount)
    }
}
