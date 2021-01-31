//
//  My_CitadelApp.swift
//  Shared
//
//  Created by Maxim Orlovsky on 11/16/20.
//

import SwiftUI
import MyCitadelKit

private struct CitadelEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = "USD"
}

extension EnvironmentValues {
    public var fiatUoA: String {
        get { self[CitadelEnvironmentKey.self] }
        set { self[CitadelEnvironmentKey.self] = newValue }
    }
}

@main
struct CitadelApp: App {
    var myCitadel: MyCitadelClient = MyCitadelClient()

    @State var data = DumbData().data

    var body: some Scene {
        WindowGroup {
            ContentView(data: $data)
        }
    }
}
