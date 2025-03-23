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
    
    func checkLoginStatus() {
        isLoggedIn = UserDefaults.standard.object(forKey: userKey) != nil
    }
    
    func saveUser(_ user: User) {
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
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userKey)
        currentUser = nil
        isLoggedIn = false
    }
    
    enum UserDefaultsError: Error {
        case saveFailed(String)
        case userNotFound
        case decodeFailed(String)
    }
}
