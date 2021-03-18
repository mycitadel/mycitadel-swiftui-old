//
//  My_CitadelApp.swift
//  Shared
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import CitadelKit
import CoreImage.CIFilterBuiltins

public func generateQRCode(from string: String) -> Image {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let data = Data(string.utf8)
    
    filter.setValue(data, forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            #if os(macOS)
            return Image(nsImage: NSImage(cgImage: cgimg, size: NSSize(width: 512, height: 512)))
            #else
            return Image(uiImage: UIImage(cgImage: cgimg))
            #endif
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
    @State private var showingAlert = false
    @State private var alertMessage: String?
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: load).alert(isPresented: $showingAlert) {
                Alert(title: Text("Failed to initialize Citadel node"), message: Text(alertMessage!))
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

func initCitadel() {
    try! CitadelVault.runEmbeddedNode(connectingNetwork: .testnet)
    try? CitadelVault.embedded.syncAll()
    if CitadelVault.embedded.contracts.isEmpty {
        do {
            try CitadelVault.embedded.createSingleSig(named: "Default", descriptor: .segwit, enableRGB: true)
        } catch {
            fatalError("initializing default contract: \(error.localizedDescription)")
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        initCitadel()
        return true
    }
}
#endif

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        initCitadel()
    }
}
#endif
