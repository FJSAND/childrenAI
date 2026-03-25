//
//  childrenaiApp.swift
//  childrenai
//
//  Created by zhyt on 2026/3/25.
//

import SwiftUI

@main
struct childrenaiApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
