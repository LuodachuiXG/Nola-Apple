//
//  UserStore.swift
//  Nola
//
//  Created by loac on 06/04/2025.
//

import Foundation
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    
    /// 用户登录
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - success: 登录成功回调 displayName
    ///   - failure: 登录失败回调失败原因
    func login(
        username: String,
        password: String,
        success: @escaping (User) -> Void,
        failure: @escaping (String) -> Void = { _ in },
    ) {
        isLoading = true
        
        Task {
            do {
                let res = try await AdminService.login(username: username, password: password)
                isLoading = false
                // 登录成功
                success(res.data!)
            } catch let error as ApiError {
                print(error.message)
                isLoading = false
                failure(error.message)
            } catch {
                print(error.localizedDescription)
                isLoading = false
                failure(error.localizedDescription)
            }
        }
    }
}
