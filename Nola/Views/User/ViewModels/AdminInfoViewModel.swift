//
//  AdminInfoViewModel.swift
//  Nola
//
//  Created by loac on 24/04/2025.
//

import Foundation

/// 管理员信息 ViewModel
class AdminInfoViewModel: ObservableObject {
    
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
