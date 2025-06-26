//
//  AdminInfoView.swift
//  Nola
//
//  Created by loac on 12/04/2025.
//

import SwiftUI

/// 管理员信息页面设置
struct AdminInfoView: View {
    
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var vm = AdminInfoViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    
    @State private var userInfo = UserInfo(
        userId: -1,
        username: "",
        email: "",
        displayName: "",
        description: nil,
        avatar: nil,
        createDate: Date().timestampMillis,
        lastLoginDate: nil
    )
    
    @State private var showErrorAlert = false
    @State private var errorAlertMsg = ""
    
    // 是否已经获取过数据，防止重复获取
    @State private var firstRefresh = false
    
    
    // 描述
    private var desc: String {
        let d = userInfo.description ?? ""
        if !d.isEmpty {
            return d.prefix(min(5, d.count)) + "..."
        }
        return ""
    }
    
    var body: some View {
        List {
            ListItem(label: "用户名", required: true) {
                TextField("输入用户名", text: $userInfo.username)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            ListItem(label: "邮箱", required: true) {
                TextField("输入邮箱", text: $userInfo.email)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            ListItem(label: "昵称", required: true) {
                TextField("输入昵称", text: $userInfo.displayName)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            ListItem(label: "描述") {
                NavigationLink {
                    List {
                        Section("描述") {
                            ZStack {
                                TextEditor(
                                    text: Binding(
                                        get: {
                                            userInfo.description ?? ""
                                        },
                                        set: { newValue in
                                            userInfo.description = newValue
                                        }
                                    )
                                )
                                .frame(minHeight: 240)
                                .textInputAutocapitalization(.never)
                                .submitLabel(.done)
                                .disabled(isLoading)
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.defaultSpacing)
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(desc)
                            .foregroundStyle(.secondary)
                    }
                }
                
            }
            
            HStack {
                Text("头像")
                Spacer()
                AsyncImage(url: URL(string: getActualUrl(url: userInfo.avatar ?? ""))) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .frame(maxWidth: 80, maxHeight: 80)
                    } else if phase.error != nil {
                        
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: 80, maxHeight: 80)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(color: .secondary.opacity(0.2), radius: 5)
            }
        }
        .navigationTitle("管理员信息")
        .toolbar {
            Button {
                updateInfo()
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("保存")
                }
            }.disabled(isLoading)
        }
        .onAppear {
            if !firstRefresh {
                getAdminInfo()
                firstRefresh = true
            }
        }
        .messageAlert(isPresented: $showErrorAlert, message: LocalizedStringKey(errorAlertMsg))
        
    }
    
    
    ///  更新信息
    private func updateInfo() {
        if userInfo.username.isEmpty {
            errorAlertMsg = "请输入用户名"
            showErrorAlert = true
            return
        }
        
        if userInfo.email.isEmpty {
            errorAlertMsg = "请输入邮箱"
            showErrorAlert = true
            return
        }
        
        if userInfo.displayName.isEmpty {
            errorAlertMsg = "请输入昵称"
            showErrorAlert = true
            return
        }
        
        
        isLoading = true
        vm.updateAdminInfo(
            username: userInfo.username,
            email: userInfo.email,
            displayName: userInfo.displayName,
            description: userInfo.description,
            avatar: userInfo.avatar,
            success: {
                // 获取最新的管理员数据
                getAdminInfo()
                dismiss()
            },
            failure: { err in
                isLoading = false
                errorAlertMsg = err
                showErrorAlert = true
            }
        )
    }
    
    /// 获取信息
    private func getAdminInfo() {
        isLoading = true
        vm.getAdminInfo { userInfo in
            isLoading = false
            self.userInfo = userInfo
            
            // 将当前登录的用户信息保存为最新的登录信息
            if let u = authManager.currentUser {
                authManager.login(
                    User(
                        username: userInfo.username,
                        email: userInfo.email,
                        displayName: userInfo.displayName,
                        description: userInfo.description,
                        createDate: userInfo.createDate,
                        lastLoginDate: userInfo.lastLoginDate,
                        avatar: userInfo.avatar,
                        token: u.token
                    )
                )
            }
        } failure: { err in
            isLoading = false
            errorAlertMsg = err
            showErrorAlert = true
        }
        
    }
}

#Preview {
    NavigationStack {
        AdminInfoView()
            .environmentObject(AuthManager.shared)
    }
}
