//
//  ContentViewModel.swift
//  Nola
//
//  Created by loac on 14/04/2025.
//

import Foundation


class ContentViewModel: ObservableObject {
    
    /// 判断之前登录的用户是否还在登录状态
    /// - Parameters:
    ///   - onValid: 登录有效回调
    ///   - onExpired: 登录过期回调
    func userLoginValidate(
        onValid: @escaping () -> Void = {},
        onExpired: @escaping () -> Void = {}
    ) {
        Task {
            do {
                let res = try await AdminService.validate()
                if res.data == true {
                    // 登录有效
                    onValid()
                    return
                }
                onExpired()
            } catch {
               // 登录过期
                onExpired()
            }
        }
    }
}
