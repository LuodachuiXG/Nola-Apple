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
    
    @State private var showToast = false
    
    @State private var showLoginSheet = false
    
    private var isLight: Bool {
        colorScheme == .light
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Card {
                        HStack(alignment: .top, spacing: 20) {
                            UserAvatar()
                            VStack(alignment: .leading ,spacing: 4) {
                                if !authManager.isLoggedIn {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                        Text("未登录 Nola")
                                            .font(.custom("user_title", size: 22, relativeTo: .title ))
                                    }
                                    Text("点击登录")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .onTapGesture {
                        showLoginSheet.toggle()
                    }
                    .frame(maxHeight: 110)
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showLoginSheet) {
                    UserLoginView()
                }
            }
        }
    }
    
    
    //    private func performLogin() {
    //        isLoading = true
    //        errorMessage = nil
    //
    //        AdminService.login(username: username, password: password)
    //            .receive(on: DispatchQueue.main)
    //            .sink { completion in
    //                isLoading = false
    //                switch completion {
    //                case .finished:
    //                    break
    //                case .failure(let error):
    //                    errorMessage = error.message
    //                    showToast = true
    //                }
    //            } receiveValue: { res in
    //                if let user = res.data {
    //                    authManager.loginSuccess(user)
    //                }
    //            }.store(in: &cancellables)
    //    }
}

#Preview {
    UserView()
        .environmentObject(AuthManager.shared)
}
