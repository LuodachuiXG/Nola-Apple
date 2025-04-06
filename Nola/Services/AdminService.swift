//
//  AdminService.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation
import Combine

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
}
