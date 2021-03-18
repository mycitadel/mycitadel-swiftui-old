//
//  ConsignmentView.swift
//  My Citadel
//
//  Created by Maxim Orlovsky on 3/18/21.
//

import SwiftUI
import CitadelKit

struct ConsignmentView: View {
    @Environment(\.presentationMode) var presentationMode

    var consignment: String

    private enum AcceptanceStatus {
        case message(String)
        case error(String)
    }
    private var status: AcceptanceStatus
    
    init(consignment: String) {
        self.consignment = consignment
        do {
            let message = try CitadelVault.embedded.contracts.first!.accept(consignment: consignment)
            status = .message(message)
        } catch let error where error is CitadelError {
            status = .error((error as! CitadelError).description)
        } catch {
            status = .error(error.localizedDescription)
        }
    }
    
    var body: some View {
        List {
            switch status {
            case .message(let message):
                Text(message)
            case .error(let message):
                Section(header:
                    Text("Error accepting payment:")
                    .padding(.top)
                ) {
                    Text(message).font(.subheadline).foregroundColor(.red).italic()
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Incoming payment")
        /*.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Dismiss", action: dissmiss)
            }
        }*/
    }

    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
        presentationMode.wrappedValue.dismiss()
    }
}

struct ConsignmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsignmentView(consignment: "")
        }
    }
}
