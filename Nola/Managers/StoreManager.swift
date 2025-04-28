//
//  StoreManager.swift
//  Nola
//
//  Created by loac on 25/04/2025.
//

import Foundation
import SwiftUI

/// 键值对存储 Manager UserDefault.standard
final class StoreManager {
    static let shared = StoreManager()
    private let standard = UserDefaults.standard
    
    private init() {}
    
    func set(_ key: StoreKey, _ integer: Int) {
        standard.set(integer, forKey: key.rawValue)
    }
    
    func set(_ key: StoreKey, _ str: String) {
        standard.set(str, forKey: key.rawValue)
    }
    
    func set(_ key: StoreKey, _ data: Encodable) {
        let encoder = JSONEncoder()
        let d = try? encoder.encode(data)
        standard.set(d, forKey: key.rawValue)
    }
    
    func string(_ key: StoreKey) -> String? {
        standard.string(forKey: key.rawValue)
    }
    
    func data<T: Decodable>(_ key: StoreKey) -> T? {
        let decoder = JSONDecoder()
        guard let data = standard.data(forKey: key.rawValue) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
    
    func int(_ key: StoreKey) -> Int? {
        if let int = Int(standard.string(forKey: key.rawValue) ?? "") {
            return int
        } else {
            return nil
        }
    }
    
    func remove(_ key: StoreKey) {
        standard.removeObject(forKey: key.rawValue)
    }
    
    
    enum StoreKey: String {
        case user = "userKey"
        case baseUrl = "baseUrlKey"
    }
    
}

/// 环境键
struct StoreManagerKey: EnvironmentKey {
    // 提供环境键默认值
    static let defaultValue: StoreManager = StoreManager.shared
}

// MARK: - User 相关
extension StoreManager {
    
    /// 获取用户
    func getUser() -> User? {
        return data(.user)
    }
    
    /// 设置用户
    func setUser(_ user: User) {
        set(.user, user)
    }
    
    // 删除用户
    func removeUser() {
        remove(.user)
    }
}


// MARK: - 网络相关
extension StoreManager {
    
    /// 获取基地址
    func getBaseUrl() -> String? {
        return string(.baseUrl)
    }
    
    /// 设置基地址
    func setBaseUrl(_ url: String) {
        set(.baseUrl, url)
    }
}
