//
//  NolaApp.swift
//  Nola
//
//  Created by loac on 17/03/2025.
//

import SwiftUI

@main
struct NolaApp: App {
    // 登录状态管理
    @StateObject private var authManager = AuthManager.shared
    // Core Data
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
                .environmentObject(authManager)
                .environment(\.storeManager, StoreManager.shared)
                .environment(\.keychain, KeychainManager.shared)
                .environment(\.managedObjectContext, coreDataManager.persistentContainer.viewContext)
        }
    }
}

