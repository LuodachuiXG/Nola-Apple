//
//  CommentService.swift
//  Nola
//
//  Created by loac on 24/06/2025.
//

import Foundation

/// 评论相关接口
struct CommentService {
    
    /// 添加评论
    /// - Parameters:
    ///   - postId: 文章 ID
    ///   - parentCommentId: 父评论 ID（可选）
    ///   - replyCommentId: 回复评论 ID（可选）
    ///   - content: 评论内容
    ///   - site: 站点地址（可选）
    ///   - displayName: 名称
    ///   - email: 邮箱
    ///   - isPass: 是否通过审核
    static func addComment(
        postId: Int,
        parentCommentId: Int?,
        replyCommentId: Int?,
        content: String,
        site: String?,
        displayName: String,
        email: String,
        isPass: Bool
    ) async throws -> ApiResponse<Comment> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/comment",
            method: .post,
            parameters: [
                "postId": postId,
                "parentCommentId": parentCommentId,
                "replyCommentId": replyCommentId,
                "content": content,
                "site": site,
                "displayName": displayName,
                "email": email,
                "isPass": isPass
            ]
        )
    }
    
    /// 根据评论 ID 数组删除评论
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    static func deleteComments(
        ids: [Int]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/comment",
            method: .delete,
            array: ids
        )
    }
    
    /// 修改评论
    /// - Parameters:
    ///   - commentId: 评论 ID
    ///   - content: 评论内容
    ///   - site: 站点地址（可空，转 nil 将会删除站点地址）
    ///   - displayName: 名称
    ///   - email: 邮箱地址
    ///   - isPass: 是否通过审核
    static func updateComment(
        commentId: Int,
        content: String,
        site: String?,
        displayName: String,
        email: String,
        isPass: Bool
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/comment",
            method: .put,
            parameters: [
                "commentId": commentId,
                "content": content,
                "site": site,
                "displayName": displayName,
                "email": email,
                "isPass": isPass
            ]
        )
    }
    
    /// 根据评论 ID 数组，修改评论审核状态
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    ///   - isPass: 是否通过审核
    static func updateCommentPass(
        ids: [Int],
        isPass: Bool
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/comment/pass",
            method: .put,
            parameters: [
                "ids": ids,
                "isPass": isPass
            ]
        )
    }
    
    /// 获取评论
    /// - Parameters:
    ///   - page: 当前页（留 0 获取全部）
    ///   - size: 每页条数
    ///   - postId: 文章 ID
    ///   - commentId: 评论 ID（可选）
    ///   - parentCommentId: 父评论 ID（可选）
    ///   - isPass: 是否通过审核（可选）
    ///   - key: 关键字（内容、邮箱、名称，可选）
    ///   - sort: 排序方式（默认创建时间降序，可选）
    ///   - tree: 是否树形结构（可选，默认 false。设为 true 时，commentId、parentCommentId、isPass、key 无效）
    static func getComments(
        page: Int = 0,
        size: Int = 0,
        postId: Int?,
        commentId: Int?,
        parentCommentId: Int?,
        isPass: Bool?,
        key: String?,
        sort: CommentSort? = nil,
        tree: Bool? = false
    ) async throws -> ApiResponse<Pager<[Comment]>> {
        var query = "?page=\(page)&size=\(size)"
        if let postId {
            query += "&postId=\(postId)"
        }
        if let commentId {
            query += "&commentId=\(commentId)"
        }
        if let parentCommentId {
            query += "&parentCommentId=\(parentCommentId)"
        }
        if let isPass {
            query += "&isPass=\(isPass)"
        }
        if let key {
            query += "&key=\(key)"
        }
        if let sort {
            query += "&sort=\(sort)"
        }
        if let tree {
            query += "&tree=\(tree)"
        }

        return try await NetworkManager.shared.request(
            endpoint: "/admin/comment\(query)",
            method: .get
        )
    }
    
}
