//
//  My_CitadelApp.swift
//  Shared
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit
import CoreImage.CIFilterBuiltins

public func generateQRCode(from string: String) -> Image {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let data = Data(string.utf8)
    
    filter.setValue(data, forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return Image(uiImage: UIImage(cgImage: cgimg))
        }
    }

    return Image(systemName: "xmark.square")
}

private struct CurrencyEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = "USD"
}

extension EnvironmentValues {
    public var currencyUoA: String {
        get { self[CurrencyEnvironmentKey.self] }
        set { self[CurrencyEnvironmentKey.self] = newValue }
    }
}

@main
struct CitadelApp: App {
    @State private var data = DumbData().data
    @State private var showingAlert = false
    @State private var alertMessage: String?
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: load).alert(isPresented: $showingAlert) {
                Alert(title: Text("Failed to initialize MyCitadel node"), message: Text(alertMessage!))
            }
        }
    }
    
    private func load() {
        if let err = CitadelVault.embedded.lastError() {
            self.showingAlert = true
            self.alertMessage = err.localizedDescription
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try! CitadelVault.runEmbeddedNode(connectingNetwork: .testnet)
        if let contracts = try? CitadelVault.embedded.syncContracts() {
            if contracts.isEmpty {
                try? CitadelVault.embedded.createSingleSig(named: "Default", descriptor: .segwit, enableRGB: true)
            }
        }
        return true
    }
}
