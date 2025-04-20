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
    @StateObject private var userStore = UserViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var displayName: String = ""
    @State private var desc: String = ""
    @State private var avatar: String = ""
    
    @State private var showErrorAlert = false
    @State private var errorAlertMsg = ""
    
    // 显示保存成功
    @State private var showSaveSuccess = false
    
    var body: some View {
        List {
            HStack {
                Text("*")
                    .foregroundStyle(.red)
                Text("用户名")
                Spacer()
                TextField("输入用户名", text: $username)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            HStack {
                Text("*")
                    .foregroundStyle(.red)
                Text("邮箱")
                Spacer()
                TextField("输入邮箱", text: $email)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            HStack {
                Text("*")
                    .foregroundStyle(.red)
                Text("昵称")
                Spacer()
                TextField("输入昵称", text: $displayName)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            HStack {
                Text("描述")
                Spacer()
                TextEditor(text: $desc)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .disabled(isLoading)
            }
            
            HStack {
                Text("头像")
                Spacer()
                AsyncImage(url: URL(string: getActualUrl(url: avatar))) { phase in
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
            
            Section {
                Button {
                    updateInfo()
                } label: {
                    HStack {
                        if isLoading && !showSaveSuccess {
                            ProgressView()
                        }
                        
                        if showSaveSuccess {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                            Text("保存成功")
                                .foregroundStyle(.green)
                        } else {
                            Text("完成")
                        }
                    }
                }.disabled(isLoading || showSaveSuccess)
            }
        }
        .navigationTitle("管理员信息")
        .onAppear {
            getAdminInfo()
        }
        .messageAlert(isPresented: $showErrorAlert, message: LocalizedStringKey(errorAlertMsg))
       
    }
    
    
    ///  更新信息
    private func updateInfo() {
        if username.isEmpty {
            errorAlertMsg = "请输入用户名"
            showErrorAlert = true
            return
        }
        
        if email.isEmpty {
            errorAlertMsg = "请输入邮箱"
            showErrorAlert = true
            return
        }
        
        if displayName.isEmpty {
            errorAlertMsg = "请输入昵称"
            showErrorAlert = true
            return
        }
        
        
        isLoading = true
        userStore.updateAdminInfo(
            username: username,
            email: email,
            displayName: displayName,
            description: desc,
            avatar: avatar,
            success: {
                // 获取最新的管理员数据
                getAdminInfo()
                $showSaveSuccess.toggleDuration(duration: 1.5)
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
        userStore.getAdminInfo { userInfo in
            isLoading = false
            username = userInfo.username
            email = userInfo.email
            displayName = userInfo.displayName
            desc = userInfo.description ?? ""
            avatar = userInfo.avatar ?? ""
            
            
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
    AdminInfoView()
        .environmentObject(AuthManager.shared)
}
