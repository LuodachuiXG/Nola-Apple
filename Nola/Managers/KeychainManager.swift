//
//  KeychainManager.swift
//  Nola
//
//  Created by loac on 29/04/2025.
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    private init() {}
    
    private let service = "cc.loac.nola"
    
    /// 保存已登录用户的账号和密码
    func saveLoggedUser(
        username: String,
        password: String
    ) -> Bool {
        
        let passwordData = password.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: service,
            kSecValueData as String: passwordData
        ]
        
        // 删除之前密码
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            // 保存成功
            return true
        } else {
            // 保存失败
            return false
        }
    }
    
    
    /// 根据 username 获取登录密码
    func getLoggedUserPassword(
        username: String
    ) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data, let password = String(data: data, encoding: .utf8) {
                return password
            }
        }
        
        return nil
    }
    
    // 删除已登录用户
    func removeLoggedUserPassword(
        username: String
    ) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
           return true
        } else {
            return false
        }
    }
    
    
}
