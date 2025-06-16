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
    
    /// 根据文章 ID 获取单个文章
    /// - Parameters:
    ///   - id: 文章 ID
    static func getPostById(
        id: Int,
    ) async throws -> ApiResponse<Post> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post/\(id)",
            method: .get
        )
    }
    
    /// 添加文章
    /// - Parameters:
    ///   - title: 文章标题
    ///   - autoGenerateExcerpt: 是否自动生成摘要（默认 false）
    ///   - excerpt: 文章摘要
    ///   - slug: 文章别名
    ///   - allowComment: 是否允许评论
    ///   - status: 文章状态（不能设为 DELETE，DELETE 请调用专门的删除文章接口）
    ///   - visible: 文章可见性
    ///   - content: 文章内容
    ///   - categoryId: 分类 ID
    ///   - tagIds: 标签 ID 数组
    ///   - cover: 文章封面
    ///   - pinned: 是否置顶（默认 false）
    ///   - password: 文章密码
    static func addPost(
        title: String,
        autoGenerateExcerpt: Bool?,
        excerpt: String?,
        slug: String,
        allowComment: Bool,
        status: PostStatus,
        visible: PostVisible,
        content: String,
        categoryId: Int?,
        tagIds: [Int]?,
        cover: String?,
        pinned: Bool?,
        password: String?
    ) async throws -> ApiResponse<Post> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post",
            method: .post,
            parameters: [
                "title": title,
                "autoGenerateExcerpt": autoGenerateExcerpt,
                "excerpt": excerpt,
                "slug": slug,
                "allowComment": allowComment,
                "status": status.rawValue,
                "visible": visible.rawValue,
                "content": content,
                "categoryId": categoryId,
                "tagIds": tagIds,
                "cover": cover,
                "pinned": pinned,
                "password": password
            ]
        )
    }
    
    /// 更新文章
    /// - Parameters:
    ///   - postId: 文章 ID
    ///   - title: 文章标题
    ///   - autoGenerateExcerpt: 是否自动生成摘要（默认 false）
    ///   - excerpt: 文章摘要
    ///   - slug: 文章别名
    ///   - allowComment: 是否允许评论
    ///   - status: 文章状态（不能设为 DELETE，DELETE 请调用专门的删除文章接口）
    ///   - visible: 文章可见性
    ///   - categoryId: 分类 ID
    ///   - tagIds: 标签 ID 数组
    ///   - cover: 文章封面
    ///   - pinned: 是否置顶（默认 false）
    ///   - encrypted: 文章是否加密（为 true 时需要提供 password，为 null 保持当前状态不变，为 false 删除密码）
    ///   - password: 文章密码
    static func updatePost(
        postId: Int,
        title: String,
        autoGenerateExcerpt: Bool?,
        excerpt: String?,
        slug: String,
        allowComment: Bool,
        status: PostStatus,
        visible: PostVisible,
        categoryId: Int?,
        tagIds: [Int]?,
        cover: String?,
        pinned: Bool?,
        encrypted: Bool?,
        password: String?
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post",
            method: .put,
            parameters: [
                "postId": postId,
                "title": title,
                "autoGenerateExcerpt": autoGenerateExcerpt,
                "excerpt": excerpt,
                "slug": slug,
                "allowComment": allowComment,
                "status": status.rawValue,
                "visible": visible.rawValue,
                "categoryId": categoryId,
                "tagIds": tagIds,
                "cover": cover,
                "pinned": pinned,
                "encrypted": encrypted,
                "password": password
            ]
        )
    }
    
    /// 回收文章
    /// - Parameters:
    ///   - ids: 文章 ID 数组
    static func recyclePost(
        ids: [Int]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post/recycle",
            method: .put,
            array: ids
        )
    }
    
    /// 恢复文章
    /// - Parameters:
    ///   - ids: 文章 ID 数组
    ///   - status: 文章状态（不能为 DELETE）
    static func restorePost(
        ids: [Int],
        status: PostStatus
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post/restore/\(status.rawValue)",
            method: .put,
            array: ids
        )
    }
    
    /// 彻底删除文章
    /// 只能删除处于 DELETE 状态（回收站）的文章
    /// - Parameters:
    ///   - ids: 文章 ID 数组
    static func deletePost(
        ids: [Int],
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post",
            method: .delete,
            array: ids
        )
    }
    
    
    /// 获取文章正文
    /// 此接口只能用于获取文章已经发布的正文。
    /// - Parameters:
    ///   - id: 文章 ID
    static func getPostContent(
        id: Int,
    ) async throws -> ApiResponse<PostContent> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post/publish/\(id)",
            method: .get
        )
    }
    
    /// 保存文章内容
    /// - Parameters:
    ///   - id: 文章 ID
    ///   - content: 文章内容（Markdown / PlainText）
    static func updatePostContent(
        id: Int,
        content: String
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/post/publish",
            method: .put,
            parameters: [
                "postId": id,
                "content": content
            ]
        )
    }
}
