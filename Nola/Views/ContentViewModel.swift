//
//  ContentViewModel.swift
//  Nola
//
//  Created by loac on 14/04/2025.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {

    @Published var blogOverview: BlogOverview?

    /// 刷新博客概览数据
    /// - Returns: 如果发生错误返回错误信息，成功返回 nil
    func refreshOverview() async -> String? {
        do {
            let res = try await OverviewService.getBlogOverview()
            if let data = res.data {
                withAnimation {
                    blogOverview = data
                }
            } else {
                return "未知错误"
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }

    /// 清除博客概览数据
    func clearOverview() {
        blogOverview = nil
    }


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
