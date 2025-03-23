//
//  NolaApp.swift
//  Nola
//
//  Created by loac on 17/03/2025.
//

import SwiftUI

@main
struct NolaApp: App {
    
    @StateObject private var authManager = AuthManager.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

