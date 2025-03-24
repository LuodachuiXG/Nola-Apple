//
//  UserView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI
import Combine
import PopupView

struct UserView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var showToast = false
    
    private var isLight: Bool {
        colorScheme == .light
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if authManager.isLoggedIn {
                    Text("登录成功，欢迎\(authManager.currentUser?.displayName ?? "")")
                        .foregroundStyle(.green)
                        .onTapGesture {
                            authManager.logout()
                        }
                } else {
                    TextField("用户名", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.none)
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("登录") {

                            performLogin()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
            }
            .padding()
            .navigationTitle("登录")
            .toast(isPresented: $showToast, text: errorMessage ?? "", type: .error)
        }
    }
    
    
    private func performLogin() {
        isLoading = true
        errorMessage = nil
        
        AdminService.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    errorMessage = error.message
                    showToast = true
                }
            } receiveValue: { res in
                if let user = res.data {
                    authManager.loginSuccess(user)
                }
            }.store(in: &cancellables)
    }
}

#Preview {
    UserView()
        .environmentObject(AuthManager.shared)
}
