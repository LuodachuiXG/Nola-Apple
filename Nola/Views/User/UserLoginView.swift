//
//  UserLoginView.swift
//  Nola
//
//  Created by loac on 26/03/2025.
//

import SwiftUI

struct UserLoginView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var userStore = UserStore()
    
    @State private var url = ""
    @State private var username = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?
    
    // 输入不完整错误
    @State private var showInputError = false
    
    // URL 错误
    @State private var showUrlError = false
    
    
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
                TextField("站点地址 https://", text: $url)
                    .focused($focusedField, equals: .url)
                    .textFieldStyle(.roundedBorder)
                    .shadow(color: focusedField == .url ? .gray.opacity(0.2) : .clear, radius: 10)
                    .animation(.spring, value: focusedField)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .username
                    }
                
                TextField("用户名", text: $username)
                    .focused($focusedField, equals: .username)
                    .textFieldStyle(.roundedBorder)
                    .shadow(color: focusedField == .username ? .gray.opacity(0.2) : .clear, radius: 10)
                    .animation(.spring, value: focusedField)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                
                SecureField("密码", text: $password)
                    .focused($focusedField, equals: .password)
                    .textFieldStyle(.roundedBorder)
                    .shadow(color: focusedField == .password ? .gray.opacity(0.2) : .clear, radius: 10)
                    .animation(.spring, value: focusedField)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                
                Button("登录") {
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
                    
                    userStore.login(username: username, password: password) { name in
                        print(name)
                    } failure: { err in
                        print(err)
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
    }
}

#Preview {
    UserLoginView()
}
