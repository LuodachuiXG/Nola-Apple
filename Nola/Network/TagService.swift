//
//  TagService.swift
//  Nola
//
//  Created by loac on 03/06/2025.
//

import Foundation


/// 标签相关接口
struct TagService {
    
    /// 分页获取标签
    /// - Parameters:
    ///   - page: 当前页（留 nil 或 0 获取全部）
    ///   - size: 每页条数
    static func getTags(
        page: Int = 0,
        size: Int = 0
    ) async throws -> ApiResponse<Pager<[Tag]>> {
        let query = "?page=\(page)&size=\(size)"
        return try await NetworkManager.shared.request(
            endpoint: "/admin/tag\(query)",
            method: .get
        )
    }
    
    /// 根据标签 ID 获取标签
    /// - Parameters:
    ///   - tagId: 标签 ID
    static func getTagById(
        tagId: Int
    ) async throws -> ApiResponse<Tag> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/tag/\(tagId)",
            method: .get
        )
    }
    
    /// 添加标签
    /// - Parameters:
    ///   - displayName: 标签名
    ///   - slug: 标签别名
    ///   - color: 标签颜色（可选，示例：#FFFFFF）
    /// - Returns: 添加成功返回标签实体类
    static func addTag(
        displayName: String,
        slug: String,
        color: String?
    ) async throws -> ApiResponse<Tag> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/tag",
            method: .post,
            parameters: [
                "displayName": displayName,
                "slug": slug,
                "color": color
            ]
        )
    }
    
    /// 修改标签
    /// - Parameters:
    ///   - tagId: 标签 ID
    ///   - displayName: 标签名
    ///   - slug: 标签别名
    ///   - color: 标签颜色（可选，示例：#FFFFFF）
    static func updateTag(
        tagId: Int,
        displayName: String,
        slug: String,
        color: String?
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/tag",
            method: .put,
            parameters: [
                "tagId": tagId,
                "displayName": displayName,
                "slug": slug,
                "color": color
            ]
        )
    }
    
    /// 根据标签 ID 删除标签
    /// - Parameters:
    ///   - ids: 标签 ID 数组
    static func deleteTagsById(
        ids: [Int]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/tag",
            method: .delete,
            array: ids
        )
    }
    
    /// 根据标签别名删除标签
    /// - Parameters:
    ///   - slugs: 标签别名数组
    static func deleteTagsBySlug(
        slugs: [String]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/tag/slug",
            method: .delete,
            array: slugs
        )
    }
}
