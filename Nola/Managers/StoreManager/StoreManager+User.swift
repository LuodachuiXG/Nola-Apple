//
//  StoreManager+User.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation

/// User 相关 StoreManager
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
