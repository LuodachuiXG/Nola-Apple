//
//  ContentView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var authManager: AuthManager
    
    @StateObject private var vm = ContentViewModel()
    
    // 是否现实登录过期弹窗
    @State private var showLoginExpiredAlert = false
    
    var body: some View {
        TabView {
            Tab("概览", systemImage: "waveform.path.ecg.rectangle") {
                OverviewView()
            }
            
            Tab("模块", systemImage: "xmark.triangle.circle.square") {
                ModuleView().navigationTitle("模块")
            }
            
            Tab("用户", systemImage: "person") {
                UserView()
            }
        }.onAppear {
            verifyLogin()
        }
        .messageAlert(isPresented: $showLoginExpiredAlert, message: "登录已过期")
    }
    
    
    /// 如果当前已经登录，检查登录是否还有效
    private func verifyLogin() {
        if let user = authManager.currentUser {
            // 用户不为空
            vm.userLoginValidate {
                // 登录有效
                uiLog.debug("\(user.username) 登录有效")
            } onExpired: {
                // 登录过期
                showLoginExpiredAlert = true
                authManager.logout()
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
