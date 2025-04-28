//
//  AuthManager.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation

/// 登录状态管理
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    
    private let store = StoreManager.shared
    
    private init() {
        checkLoginStatus()
    }
    
    
    /// 判断当前是否已经登录
    private func checkLoginStatus() {
        let user = store.getUser()
        isLoggedIn = user != nil
        currentUser = user
    }
    
    /// 登录成功，保存登录信息
    /// - Parameters:
    ///   - user: 用户
    func login(_ user: User) {
        let encoder = JSONEncoder()
        store.setUser(user)
        DispatchQueue.main.async {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    /// 登出
    func logout() {
        store.removeUser()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
        }
    }
}
