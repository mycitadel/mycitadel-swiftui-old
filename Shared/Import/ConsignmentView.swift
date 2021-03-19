//
//  ConsignmentView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/18/21.
//

import SwiftUI
import CitadelKit

extension ConsignmentView.AcceptanceStatus {
    var localizedName: String {
        switch self {
        case .validationStatus(let status): return status.localizedName
        case .error(_): return "Unable to process"
        }
    }
    var systemImage: String {
        switch self {
        case .validationStatus(let status): return status.systemImage
        case .error(_): return "clear.fill"
        }
    }
    var color: Color {
        switch self {
        case .validationStatus(let status): return status.color
        case .error(_): return Color.secondary
        }
    }
    var failures: [String] {
        switch self {
        case .validationStatus(let status): return status.failures
        case .error(let err): return [err]
        }
    }
    var warnings: [String] {
        switch self {
        case .validationStatus(let status): return status.warnings
        case .error(_): return []
        }
    }
    var info: [String] {
        switch self {
        case .validationStatus(let status): return status.info
        case .error(_): return []
        }
    }
}

struct ConsignmentView: View {
    @Environment(\.presentationMode) var presentationMode

    var consignment: String

    fileprivate enum AcceptanceStatus {
        case validationStatus(ValidationStatus)
        case error(String)
    }
    private var status: AcceptanceStatus

    @Binding var presentedSheet: PresentedSheet?

    init(consignment: String, presentedSheet: Binding<PresentedSheet?>) {
        self._presentedSheet = presentedSheet
        self.consignment = consignment

        do {
            let validationStatus = try CitadelVault.embedded.contracts.first!.accept(consignment: consignment)
            status = .validationStatus(validationStatus)
        } catch let error where error is CitadelError {
            status = .error((error as! CitadelError).description)
        } catch {
            status = .error(error.localizedDescription)
        }
    }
    
    var body: some View {
        List {
            resultView
            
            if !status.failures.isEmpty {
                Section(header: Text("Failures:")) {
                    ForEach(status.failures, id: \.self) { message in
                        Text(message)
                            .foregroundColor(.red)
                    }
                }
            }

            if !status.warnings.isEmpty {
                Section(header: Text("Warnings:")) {
                    ForEach(status.warnings, id: \.self) { message in
                        Text(message)
                    }
                }
            }

            if !status.info.isEmpty {
                Section(header: Text("Additional info:")) {
                    ForEach(status.info, id: \.self) { message in
                        Text(message)
                    }
                }
            }
        }
        .navigationTitle("Accepting payment")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Dismiss", action: dissmiss)
            }
        }
    }
    
    var resultView: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Image(systemName: status.systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                    .opacity(0.666)
                    .foregroundColor(status.color)
                Text(status.localizedName)
                    .font(.largeTitle)
                    .padding(.top)
            }
            Spacer()
        }.padding([.top, .bottom], 50)
    }

    private func dissmiss() {
        presentedSheet = nil
    }
}

struct ConsignmentView_Previews: PreviewProvider {
    @State static private var presentedSheet: PresentedSheet? = nil
    static var previews: some View {
        NavigationView {
            ConsignmentView(consignment: "", presentedSheet: $presentedSheet)
        }
    }
}
