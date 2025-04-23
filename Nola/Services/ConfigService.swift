//
//  ConfigService.swift
//  Nola
//
//  Created by loac on 24/04/2025.
//

import Foundation

/// 配置信息相关接口
struct ConfigService {
    
    /// 获取博客信息
    static func getBlogInfo() async throws -> ApiResponse<BlogInfo> {
        // 目前该接口还未新增 admin，目前先用 api
        return try await NetworkManager.shared.request(
            endpoint: "/api/config/blog",
            method: .get,
        )
    }
    
    /// 修改博客信息
    static func updateBlogInfo(
        title: String,
        subtitle: String?,
        logo: String?,
        favicon: String?
    ) async throws -> ApiResponse<Bool> {
        let params = [
            "title": title,
            "subtitle": subtitle,
            "logo": logo,
            "favicon": favicon,
        ]
        
        return try await NetworkManager.shared.request(
            endpoint: "/admin/config/blog",
            method: .put,
            parameters: params
        )
    }
    
    /// 获取备案信息
    static func getIcp() async throws -> ApiResponse<ICP> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/config/icp",
            method: .get,
        )
    }
    
    /// 修改备案信息
    static func updateIcp(
        icp: String?,
        `public`: String?
    ) async throws -> ApiResponse<Bool> {
        let params = [
            "icp": icp,
            "public": `public`
        ]
        
        return try await NetworkManager.shared.request(
            endpoint: "/admin/config/icp",
            method: .put,
            parameters: params
        )
    }
}
