//
//  AuthManager.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation


class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    
    private let userKey = "userKey"
    
    init() {
        checkLoginStatus()
    }
    
    /// 判断当前是否已经登录
    func checkLoginStatus() {
        let userData = UserDefaults.standard.data(forKey: userKey)
        isLoggedIn = userData != nil
        if let data = userData {
            let decoder = JSONDecoder()
            currentUser = try? decoder.decode(User.self, from: data)
        }
    }
    
    /// 登录成功，保存登录信息
    /// - Parameters:
    ///   - user: 用户
    func loginSuccess(_ user: User) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: userKey)
            currentUser = user
            isLoggedIn = true
        } catch {
            print(error)
        }
    }
    
    /// 登出
    func logout() {
        UserDefaults.standard.removeObject(forKey: userKey)
        currentUser = nil
        isLoggedIn = false
    }
}
