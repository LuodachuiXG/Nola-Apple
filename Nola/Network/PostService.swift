//
//  PostService.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation


/// 文章相关接口
struct PostService {
    
    /// 获取文章
    /// - Parameters:
    ///   - page: 当前页（留 nil 或 0 获取全部）
    ///   - size: 每页条数
    ///   - status: 文章状态（默认不获取处于删除状态的文章，除非显示指定）
    ///   - visible: 文章可见性
    ///   - key: 关键词（标题、别名、摘要、内容）
    ///   - tag: 标签 ID
    ///   - category: 分类 ID
    ///   - sort: 文章排序（默认创建时间降序）
    static func getPosts(
        page: Int = 0,
        size: Int = 0,
        status: PostStatus? = nil,
        visible: PostVisible? = nil,
        key: String? = nil,
        tag: Int? = nil,
        category: Int? = nil,
        sort: PostSort? = nil
    ) async throws -> ApiResponse<Pager<[Post]>> {
        var query = "?page=\(page)&size=\(size)"
        if let status {
            query += "&status=\(status)"
        }
        if let visible {
            query += "&visible=\(visible)"
        }
        if let key {
            query += "&key=\(key)"
        }
        if let tag {
            query += "&tag=\(tag)"
        }
        if let category {
            query += "&category=\(category)"
        }
        if let sort {
            query += "&sort=\(sort)"
        }
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post\(query)",
            method: .get
        )
    }
}
