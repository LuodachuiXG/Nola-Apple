//
//  UserLoginView.swift
//  Nola
//
//  Created by loac on 26/03/2025.
//

import SwiftUI
import LocalAuthentication


// 用户登陆页面
struct UserLoginView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.keychain) private var keychain
    
    @EnvironmentObject private var authManager: AuthManager
    
    @StateObject private var viewModel = UserViewModel()
    
    // 当前 Sheet 是否显示
    @Binding var isPresented: Bool
    
    @State private var url = ""
    @State private var username = ""
    @State private var password = ""
    
    // 当前焦点输入框
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case url, username, password
    }
    
    // 输入不完整错误
    @State private var showInputError = false
    
    // URL 错误
    @State private var showUrlError = false
    
    // 登录错误
    @State private var showLoginError = false
    @State private var loginErrorStr = ""
    
    @State private var isLoading = false
    
    // 以前登录过的用户记录列表（用于控制是否显示快速登录按钮）
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserRecord.lastLoginTime, ascending: false)],
        animation: .default
    )
    private var userRecords: FetchedResults<UserRecord>

    // 是否显示快速登录按钮（上面的 userRecords 不为空时，默认启用，除非用户手动选择登录其他账号）
    @State private var enableQuickLogin = true
    
    var body: some View {
        VStack(alignment: .center, spacing: .defaultSpacing) {
            Image(.nolaBackgroundTransparent)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            
            
            VStack(alignment: .trailing, spacing: 20) {
                if authManager.isLoggedIn {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundStyle(.green)
                            .padding()
                        Text("登录成功")
                            .font(.title)
                    }
                    .transition(.blurReplace)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            // 关闭登录 sheet
                            $isPresented.wrappedValue = false
                        }
                    }
                } else {
                    
                    if !userRecords.isEmpty && enableQuickLogin {
                        // 用户登录记录不为空，并且启用快速登录
                        Button {
                            // 快速登录
                            quickLogin()
                        } label: {
                            LoggedUser(
                                record: userRecords.first!
                            )
                        }.disabled(isLoading)

                        
                        if isLoading {
                            ProgressView()
                        } else {
                            Button("登录其他账号") {
                                enableQuickLogin = false
                            }
                        }
                    } else {
                        TextField("站点地址 https://", text: $url)
                            .focused($focusedField, equals: .url)
                            .textFieldStyle(.roundedBorder)
                            .shadow(color: focusedField == .url ? .gray.opacity(0.2) : .clear, radius: 10)
                            .animation(.spring, value: focusedField)
                            .submitLabel(.next)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                focusedField = .username
                            }
                        
                        TextField("用户名", text: $username)
                            .focused($focusedField, equals: .username)
                            .textFieldStyle(.roundedBorder)
                            .shadow(color: focusedField == .username ? .gray.opacity(0.2) : .clear, radius: 10)
                            .animation(.spring, value: focusedField)
                            .submitLabel(.next)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                focusedField = .password
                            }
                        
                        SecureField("密码", text: $password)
                            .focused($focusedField, equals: .password)
                            .textFieldStyle(.roundedBorder)
                            .shadow(color: focusedField == .password ? .gray.opacity(0.2) : .clear, radius: 10)
                            .animation(.spring, value: focusedField)
                            .submitLabel(.done)
                            .textContentType(.password)
                            .onSubmit {
                                focusedField = nil
                            }
                        
                        if isLoading {
                            ProgressView()
                        } else {
                            Button("登录") {
                                // 改变焦点，收起键盘
                                focusedField = nil
                                
                                login()
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            Spacer()
            Text("请确保已经在网页端后台完成博客初始化")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, .defaultSpacing)
        }
        .padding([.top, .leading, .trailing], 40)
        .messageAlert(isPresented: $showInputError, message: "请将内容输入完整")
        .messageAlert(isPresented: $showUrlError, message: "请输入正确的站点地址")
        .messageAlert(isPresented: $showLoginError, message: LocalizedStringKey(loginErrorStr))
        .loadingAlert(isPresented: $isLoading, message: "正在登录", closableAfter: .seconds(5))
    }
    
    
    private func login() {
        isLoading = true
        
        if url.isEmpty || username.isEmpty || password.isEmpty {
            showInputError = true
            isLoading = false
            return
        }
        
        if !url.isValidUrl() {
            // 站点地址不合法
            showUrlError = true
            isLoading = false
            return
        }
        
        // 先配置服务器地址
        NetworkManager.shared.setBaseUrl(url: url)
        
        viewModel.login(username: username, password: password) { user in
            // 登录成功
            
            // 将密码保存到 keychain
            if keychain.saveLoggedUser(username: username, password: password) {
                // 将已登录的账号添加到 CoreData
                let userRecord = UserRecord(context: viewContext)
                userRecord.id = UUID()
                userRecord.url = url
                userRecord.username = username
                userRecord.lastLoginTime = Date()
                userRecord.avatar = user.avatar ?? ""
                viewContext.saveIfHasChange()
            }
            
            withAnimation(.snappy) {
                isLoading = false
                authManager.login(user)
            }
        } failure: { err in
            isLoading = false
            loginErrorStr = err
            showLoginError = true
        }
    }
    
    /// 快速登录
    /// 使用已有的登录记录，通过验证 FaceID 或密码来快速登录
    private func quickLogin() {
        isLoading = true
        
        let context = LAContext()
        var error: NSError?
        
        // 检查验证可行性
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "验证身份以继续操作"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, err in
                DispatchQueue.main.async {
                    if success {
                        // 验证成功
                        let userRecord = userRecords.first!
                        // 从 keychain 获取密码
                        guard let pwd = keychain.getLoggedUserPassword(username: userRecord.username) else {
                            loginErrorStr = "快速登录失败，请手动重新登录"
                            showLoginError = true
                            enableQuickLogin = false
                            isLoading = false
                            return
                        }
                        
                        // 填充登录信息
                        url = userRecord.url
                        username = userRecord.username
                        password = pwd
                        
                        // 登录
                        login()
                        
                    } else {
                        // 验证失败
                        print(err?.localizedDescription ?? "未知错误")
                        loginErrorStr = err?.localizedDescription ?? "无法验证身份，请尝试手动输入账号密码登录"
                        showLoginError = true
                        isLoading = false
                    }
                }
            }
        } else {
            print(error?.localizedDescription ?? "无法验证")
            loginErrorStr = error?.localizedDescription ?? "无法验证身份，请尝试手动输入账号密码登录"
            showLoginError = true
            isLoading = false
        }
    }
}

// MARK: - 登录过的账号选择
private struct LoggedUser: View {
    
    // 登录的记录
    var record: UserRecord
    
    var body: some View {
        HStack(alignment: .center) {
            UserAvatar(
                displayName: record.displayName,
                avatar: record.avatar,
                width: 36
            )
            .padding(.defaultSpacing)
            
            Text("Loac")
                .font(.title3)
                .foregroundStyle(Color.primary)
            
            Spacer()
            
            Text("最近登录")
                .padding(.trailing, .defaultSpacing)
                .font(.callout)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
}

#Preview {
    UserLoginView(isPresented: .constant(true))
        .environment(\.managedObjectContext, CoreDataManager.preview.persistentContainer.viewContext)
        .environmentObject(AuthManager.shared)
        .environment(\.storeManager, StoreManager.shared)
        .environment(\.keychain, KeychainManager.shared)
        
}
