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
                            UserAvatar(user: authManager.currentUser)
                            VStack(alignment: .leading ,spacing: 4) {
                                if !authManager.isLoggedIn {
                                    // 未登录
                                    HStack {
                                        Image(systemName: "lock.fill")
                                        Text("未登录 Nola")
                                            .font(.custom("user_title", size: 22, relativeTo: .title ))
                                    }
                                    Text("点击登录")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                } else {
                                    // 已登录
                                    UserDetail(user: authManager.currentUser!)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .onTapGesture {
                        // 如果当前未登录，显示登录页面
                        if !authManager.isLoggedIn {
                            showLoginSheet.toggle()
                        } else {
                            // 当前已登录，点击后退出登录（#### 测试代码 ####）
                            authManager.logout()
                            showLoginSheet.toggle()
                        }
                    }
                    .frame(maxHeight: 110)
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showLoginSheet) {
                    UserLoginView(isPresented: $showLoginSheet)
                }
            }
        }
    }
}

private struct UserDetail: View {
    
    var user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(user.displayName)
                .font(.title2)
                .fontDesign(.rounded)
            
            Text(user.email)
                .foregroundStyle(.secondary)
                .fontDesign(.serif)
                .font(.callout)
            
            Spacer()
            if let last = user.lastLoginDate {
                Text("上次登录：" + last.formatMillisToDateStr())
                    .foregroundStyle(.tertiary)
                    .fontDesign(.rounded)
                    .font(.caption)
            }

        }
    }
}

#Preview {
    UserView()
        .environmentObject(AuthManager.shared)
}
