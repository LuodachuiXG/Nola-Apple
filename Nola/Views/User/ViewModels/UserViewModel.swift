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
        Task {
            do {
                let res = try await AdminService.login(username: username, password: password)
                // 登录成功
                success(res.data!)
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
    
    /// 修改管理员信息
    func updateAdminInfo(
        username: String,
        email: String,
        displayName: String,
        description: String?,
        avatar: String?,
        success: @escaping () -> Void,
        failure: @escaping (String) -> Void = { _ in }
    ) {
        Task {
            do {
                _ = try await AdminService.updateAdminInfo(
                    username: username,
                    email: email,
                    displayName: displayName,
                    description: description,
                    avatar: avatar
                )
                success()
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
    
    /// 获取管理员信息
    func getAdminInfo(
        success: @escaping (UserInfo) -> Void,
        failure: @escaping (String) -> Void
    ) {
        Task {
            do {
                let res = try await AdminService.getAdminInfo()
                if let user = res.data {
                    success(user)
                } else {
                    failure("获取管理员信息失败")
                }
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
}
