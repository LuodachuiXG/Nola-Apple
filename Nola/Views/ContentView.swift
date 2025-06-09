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

    @State private var showErrorDialog = false
    @State private var errorDialogMsg = ""

    var body: some View {
        TabView {
            Tab("概览", systemImage: "waveform.path.ecg.rectangle") {
                OverviewView(contentVM: vm)
            }

            Tab("模块", systemImage: "xmark.triangle.circle.square") {
                ModuleView(contentVM: vm)
            }

            Tab("用户", systemImage: "person") {
                UserView()
            }
        }.task {
            verifyLogin()
        }.onChange(of: authManager.isLoggedIn, { oldValue, newValue in
            if !oldValue && newValue {
                // 用户登陆，刷新博客概览数据
                refreshOverview()
            } else if oldValue && !newValue {
                // 用户登录退出
                vm.clearOverview()
            }
        })
        .messageAlert(isPresented: $showLoginExpiredAlert, message: "登录已过期")
        .messageAlert(isPresented: $showErrorDialog, message: LocalizedStringKey(errorDialogMsg))
    }

    /// 刷新博客概览数据
    private func refreshOverview() {
        Task {
            if let err = await vm.refreshOverview() {
                self.errorDialogMsg = err
                self.showErrorDialog = true
            }
        }
    }


    /// 如果当前已经登录，检查登录是否还有效
    private func verifyLogin() {
        if let user = authManager.currentUser {
            // 用户不为空
            vm.userLoginValidate {
                // 登录有效
                uiLog.debug("\(user.username) 登录有效")

                // 获取博客概览数据
                refreshOverview()
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
        .environment(\.managedObjectContext, CoreDataManager.preview.persistentContainer.viewContext)
        .environmentObject(AuthManager.shared)
}
