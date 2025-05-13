//
//  AdminService.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation

/// 管理员相关接口
struct AdminService {
    
    /// 登录接口
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    static func login(
        username: String,
        password: String
    ) async throws -> ApiResponse<User> {
        let parameters = [
            "username": username,
            "password": password
        ]
        
        return try await NetworkManager.shared.request(
            endpoint: "/admin/user/login",
            method: .post,
            parameters: parameters
        )
    }
    
    /// 登录有效性检查
    static func validate() async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/user/validate",
            method: .get
        )
    }
    
    /// 获取管理员信息
    static func getAdminInfo() async throws -> ApiResponse<UserInfo> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/user",
            method: .get
        )
    }
    
    
    /// 修改管理员信息
    static func updateAdminInfo(
        username: String,
        email: String,
        displayName: String,
        description: String?,
        avatar: String?
    ) async throws -> ApiResponse<Bool> {
        let params = [
            "username": username,
            "email": email,
            "displayName": displayName,
            "description": description,
            "avatar": avatar
        ]
        
        return try await NetworkManager.shared.request(
            endpoint: "/admin/user",
            method: .put,
            parameters: params
        )
    }
    
    /// 修改管理员密码
    /// - Parameters:
    ///   - password: 新密码
    static func updateAdminPassword(
        password: String
    ) async throws -> ApiResponse<Bool> {
        let params = [
            "password": password
        ]
        
        return try await NetworkManager.shared.request(
            endpoint: "/admin/user/password",
            method: .put,
            parameters: params
        )
    }
}
