//
//  UserView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI
import Combine

struct UserView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var cancellables = Set<AnyCancellable>()
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                if authManager.isLoggedIn {
                    Text("登录成功")
                        .foregroundStyle(.green)
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
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
                
            }
            .padding()
            .navigationTitle("登录")
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
                }
            } receiveValue: { res in
                if let user = res.data {
                    authManager.saveUser(user)
                }
            }.store(in: &cancellables)
    }
}

#Preview {
    UserView()
}
