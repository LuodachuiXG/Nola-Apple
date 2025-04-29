//
//  UserView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI
import Combine
import PopupView

// MARK: - 用户页面
struct UserView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var showToast = false
    
    @State private var showLoginSheet = false
    
    @State private var showLogoutAlert = false
    
    private var isLight: Bool {
        colorScheme == .light
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Card {
                        HStack(alignment: .top, spacing: 20) {
                            UserAvatar(
                                displayName: authManager.currentUser?.displayName ?? "Nola",
                                avatar: authManager.currentUser?.avatar
                            )
                            VStack(alignment: .leading ,spacing: 4) {
                                if !authManager.isLoggedIn {
                                    // 未登录
                                    HStack {
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
                        }
                    }
                    .frame(maxHeight: 110)
                    
                    // 底部控制面板
                    ControllerPanelView(user: authManager.currentUser) {
                        showLogoutAlert = true
                    }
                }
                .padding()
                .sheet(isPresented: $showLoginSheet) {
                    UserLoginView(isPresented: $showLoginSheet)
                }
                .confirmAlert(isPresented: $showLogoutAlert, message: "确定要退出登录吗") {
                    authManager.logout()
                }
            }
        }
    }
}

// MARK: - 用户详细信息
private struct UserDetail: View {
    
    var user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(user.displayName)
                .font(.title2)
            
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



// MARK: - 控制面板
private struct ControllerPanelView: View {
    
    var user: User?
    
    // 退出登录点击事件
    var onLogoutClick: () -> Void = {}
    
    
    private var groups: [UserControllerGroup] {
        
        var group = [
            UserControllerGroup(name: "BLOG", items: [
                UserControllerItem(icon: "person.circle", name: "管理员信息", destination: AdminInfoView()),
                UserControllerItem(icon: "gear.circle", name: "博客设置", destination: BlogSettingView()),
                UserControllerItem(icon: "arrow.clockwise.circle", name: "博客备份", destination: BlogBackupView())
            ])
        ]
        
        // 登录后才显示退出登录的按钮
        if user != nil {
            group.append(
                UserControllerGroup(name: "APP", items: [
                    UserControllerItem(icon: "arrow.left.circle", name: "退出登录") {
                        onLogoutClick()
                    }
                ])
            )
        }
        
        return group
    }
    
    var body: some View {
        VStack(spacing: .defaultSpacing) {
            ForEach(groups, id: \.id) { group in
                ControllerPanelGroup(group: group, user: user)
            }
        }
        .fontDesign(.rounded)
    }
    
    
    /// 控制面板组
    private struct ControllerPanelGroup: View {
        
        let group: UserControllerGroup
        
        let user: User?
        
        // 是否显示提示未登录弹窗
        @State private var showNotLoginAlert = false
        
        var body: some View {
            Section {
                ForEach(group.items, id: \.id) { item in
                    if item.destination != nil {
                        NavigationLink {
                            item.destination
                        } label: {
                            ControllerPanelItemView(item: item)
                        }
                        .disabled(user == nil && group.auth)
                        .onTapGesture {
                            if user == nil && group.auth {
                                showNotLoginAlert = true
                            }
                        }
                    } else {
                        Button(action: item.onClick) {
                            ControllerPanelItemView(item: item)
                        }
                    }
                }
            } header: {
                Text(group.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .top], .defaultSpacing)
                    .fontDesign(.rounded)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .messageAlert(isPresented: $showNotLoginAlert, message: "请先登录 Nola")
        }
    }
    
    /// 控制面板点击项
    private struct ControllerPanelItemView: View {
        
        var item: UserControllerItem
        
        var body: some View {
            Card {
                HStack(alignment: .center, spacing: .defaultSpacing) {
                    Image(systemName: item.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                        .symbolEffect(.rotate.byLayer, options: .speed(3).nonRepeating)
                    Text(item.name)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 6)
                        .foregroundStyle(.secondary)
                        .symbolEffect(.bounce.down.byLayer, options: .nonRepeating)
                }
                .foregroundStyle(.foreground)
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }
}



#Preview {
    UserView()
        .environmentObject(AuthManager.shared)
}
