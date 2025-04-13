//
//  UserLoginView.swift
//  Nola
//
//  Created by loac on 26/03/2025.
//

import SwiftUI

struct UserLoginView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var userStore = UserViewModel()
    
    @Binding var isPresented: Bool
    
    @State private var url = ""
    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?
    
    // 输入不完整错误
    @State private var showInputError = false
    
    // URL 错误
    @State private var showUrlError = false
    
    // 登录错误
    @State private var showLoginError = false
    @State private var loginErrorStr = ""
    
    
    private enum Field: Hashable {
        case url, username, password
    }
    
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
                    TextField("站点地址 https://", text: $url)
                        .focused($focusedField, equals: .url)
                        .textFieldStyle(.roundedBorder)
                        .shadow(color: focusedField == .url ? .gray.opacity(0.2) : .clear, radius: 10)
                        .animation(.spring, value: focusedField)
                        .submitLabel(.next)
                        .textContentType(.URL)
#if os(iOS)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
#endif
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
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
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
                    
                    if userStore.isLoading {
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
        .loadingAlert(isPresented: $userStore.isLoading, message: "正在登录", closableAfter: .seconds(5))
    }
    
    
    private func login() {
        if url.isEmpty || username.isEmpty || password.isEmpty {
            showInputError = true
            return
        }
        
        if !url.isValidUrl() {
            // 站点地址不合法
            showUrlError = true
            return
        }
        
        // 先配置服务器地址
        NetworkManager.shared.setBaseUrl(url: url)
        
        userStore.login(username: username, password: password) { user in
            // 登录成功
            withAnimation(.snappy) {
                authManager.login(user)
            }
        } failure: { err in
            loginErrorStr = err
            showLoginError = true
        }
    }
}

#Preview {
    UserLoginView(isPresented: .constant(true))
        .environmentObject(AuthManager.shared)
}
