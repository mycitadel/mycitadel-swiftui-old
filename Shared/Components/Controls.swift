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
            /*
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
            */
    }
}

struct CopyableText: View {
    let text: String
    var copyable: Bool = false
    var multilineTextAlignment = TextAlignment.leading
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
    let title: String
    let details: String
    var subdetails: String?
    var clipboardCopy: Bool = false
    
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
    let title: String
    let details: String
    var clipboardCopy: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Spacer()
            CopyableText(text: details, copyable: clipboardCopy, useSpacer: true)
        }.padding(.vertical, 6)
    }
}

struct BechBrief: View {
    let text: String
    
    private var isBase58: Bool {
        for prefix in ["1", "2", "3", "n", "m"] {
            if text.hasPrefix(prefix) {
                return true
            }
        }
        return false
    }
    
    private var hrp: String {
        isBase58
            ? String(text.prefix(1))
            : String(text.prefix(while: { $0 != "1" })) + "1"
    }
    private var checksum: String {
        isBase58 ? "" : String(text.suffix(6))
    }
    private var mainPart: String {
        String(text.dropFirst(hrp.count + 1).dropLast(isBase58 ? 0 : 6))
    }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(hrp.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
                .layoutPriority(1)
                .lineLimit(1)
            Text(mainPart.lowercased())
                .font(.footnote)
                .truncationMode(.middle)
                .fixedSize()
                .lineLimit(1)
            Text(checksum)
                .font(.subheadline)
                .bold()
                .layoutPriority(1)
                .lineLimit(1)
        }
    }
}

struct Controls_Previews: PreviewProvider {
    @State static var amount: String = ""
    static var previews: some View {
        AmountField(placeholder: "Amount", units: .accounting, amount: $amount)
    }
}
