//
//  OverviewManager.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 概览相关接口
struct OverviewService {
    
    /// 获取博客概览数据
    static func getBlogOverview() async throws -> ApiResponse<BlogOverview> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/overview",
            method: .get,
        )
    }
}
