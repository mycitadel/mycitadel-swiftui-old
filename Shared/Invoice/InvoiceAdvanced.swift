//
//  CreateInvoice.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 2/24/21.
//

import SwiftUI
import Combine
import MyCitadelKit

struct InvoiceAdvanced: View {
    @ObservedObject var invoiceConfig: InvoiceConfig
    @State private var frequency: UInt8 = 1 {
        didSet {
            updateRecurrency()
        }
    }
    
    private func frequencyName(_ interval: String) -> String {
        frequency == 1 ? interval : "\(frequency) \(interval)s"
    }
    private func checkMark(by name: String) -> String {
        switch (name, invoiceConfig.recurrent) {
        case ("second", .bySecond(_)): return "checkmark"
        case ("minute", .byMinute(_)): return "checkmark"
        case ("hour", .byHour(_)): return "checkmark"
        case ("day", .byDay(_)): return "checkmark"
        case ("week", .byWeek(_)): return "checkmark"
        case ("month", .byMonth(_)): return "checkmark"
        case ("year", .byYear(_)): return "checkmark"
        default: return ""
        }
    }
    private func updateRecurrency() {
        switch invoiceConfig.recurrent {
        case .bySecond(_): invoiceConfig.recurrent = .bySecond(frequency)
        case .byMinute(_): invoiceConfig.recurrent = .byMinute(frequency)
        case .byHour(_): invoiceConfig.recurrent = .byHour(frequency)
        case .byDay(_): invoiceConfig.recurrent = .byDay(frequency)
        case .byWeek(_): invoiceConfig.recurrent = .byWeek(frequency)
        case .byMonth(_): invoiceConfig.recurrent = .byMonth(frequency)
        case .byYear(_): invoiceConfig.recurrent = .byYear(frequency)
        }
    }
   
    var body: some View {
        Form {
            Section(header: VStack(alignment: .leading) {
                Text("Allow payment to be")
                Picker("", selection: $invoiceConfig.repeated) {
                    Text("Single").tag(RepeatedPayments.single)
                    Text("Multiple").tag(RepeatedPayments.multiple)
                    Text("Regular").tag(RepeatedPayments.recurrent)
                }
                .pickerStyle(SegmentedPickerStyle())
            }) {
                if invoiceConfig.repeated == .recurrent {
                    Stepper(value: $frequency, in: 1...60) {
                        Text("should happen each")
                    }
                    Button(action: { invoiceConfig.recurrent = .bySecond(frequency) }) {
                        Label(frequencyName("second"), systemImage: checkMark(by: "second"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byMinute(frequency) }) {
                        Label(frequencyName("minute"), systemImage: checkMark(by: "minute"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byHour(frequency) }) {
                        Label(frequencyName("hour"), systemImage: checkMark(by: "hour"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byDay(frequency) }) {
                        Label(frequencyName("day"), systemImage: checkMark(by: "day"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byWeek(frequency) }) {
                        Label(frequencyName("week"), systemImage: checkMark(by: "week"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byMonth(frequency) }) {
                        Label(frequencyName("month"), systemImage: checkMark(by: "month"))
                    }.foregroundColor(.primary)
                    Button(action: { invoiceConfig.recurrent = .byYear(frequency) }) {
                        Label(frequencyName("year"), systemImage: checkMark(by: "year"))
                    }.foregroundColor(.primary)
                }
                /*
                Toggle(isOn: $invoiceConfig.multiple) {
                    Text("Allow multple paymets")
                }
                 */
            }

            Section(header: Toggle(isOn: $invoiceConfig.usePurpose) {
                Text("Describe invoice purpose")
            }) {
                if invoiceConfig.usePurpose {
                    TextField("Write some purpose explanation", text: $invoiceConfig.purpose)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                }
            }

            Section(header: Toggle(isOn: $invoiceConfig.useMerchant) {
                Text("Name yourself")
            }) {
                if invoiceConfig.useMerchant {
                    TextField("Yourself or your company", text: $invoiceConfig.merchant)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                }
            }

            Section(header: Toggle(isOn: $invoiceConfig.useExpiry) {
                Text("Set expiration")
            }) {
                if invoiceConfig.useExpiry {
                    DatePicker(selection: $invoiceConfig.expiry, label: { EmptyView() })
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
        }
        .navigationTitle("Advanced options")
    }
}

struct InvoiceAdvanced_Previews: PreviewProvider {
    @StateObject static var config: InvoiceConfig = {
        let config = InvoiceConfig()
        config.useExpiry = true
        config.useExpiry = true
        config.amountType = .perItem
        config.amount = "1"
        config.repeated = .multiple
        config.quantity.limitMin = true
        config.quantity.limitMax = true
        config.usePurpose = true
        config.useMerchant = true
        config.useDetails = true
        return config
    }()
    
    static var previews: some View {
        NavigationView {
            InvoiceAdvanced(invoiceConfig: Self.config)
        }
    }
}
