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
    
    @EnvironmentObject private var authManager: AuthManager
    
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
    
    @State private var isLoading = false
    
    // 以前登录过的用户记录列表
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserRecord.createTime, ascending: false)],
        animation: .default
    )
    private var userRecords: FetchedResults<UserRecord>
    
    private enum Field: Hashable {
        case url, username, password
    }
    
    @State private var selected = 0
    
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
                    
                    LoggedUser()
                    
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
        
        userStore.login(username: username, password: password) { user in
            isLoading = false
            // 登录成功
            withAnimation(.snappy) {
                authManager.login(user)
            }
        } failure: { err in
            isLoading = false
            loginErrorStr = err
            showLoginError = true
        }
    }
}

// MARK: - 登录过的账号选择
private struct LoggedUser: View {
    
    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: URL(string: "https://loac.cc/logo")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36)
                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            } placeholder: {
                ProgressView()
                    .frame(width: 36, height: 36)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2), lineWidth: 1)
            }
            .padding(.defaultSpacing)
            
            Text("Loac")
                .font(.title3)
            
            Spacer()
            
            Text("最近登录")
                .padding(.trailing, .defaultSpacing)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .onTapGesture {
            let context = LAContext()
            var error: NSError?
            
            print(context.biometryType.rawValue)
            
            // 检查验证可行性
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "验证以继续操作"
                
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, err in
                    DispatchQueue.main.async {
                        if success {
                            // 验证成功
                            print("验证通过")
                        } else {
                            // 验证失败
                            print(err?.localizedDescription ?? "未知错误")
                        }
                    }
                }
            } else {
                print(error?.localizedDescription ?? "无法验证")
            }
        }
        
    }
}

#Preview {
    UserLoginView(isPresented: .constant(true))
        .environmentObject(AuthManager.shared)
        .environment(\.storeManager, StoreManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.preview.persistentContainer.viewContext)
}
