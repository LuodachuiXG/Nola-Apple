//
//  Comment.swift
//  Nola
//
//  Created by loac on 24/06/2025.
//

import Foundation

/// 评论实体
struct Comment: Codable {
    /// 评论 ID
    let commentId: Int
    /// 文章 ID
    let postId: Int
    /// 文章标题（可空）
    let postTitle: String?
    /// 父评论 ID（可空）
    let parentCommentId: Int?
    /// 回复评论 ID（可空）
    let replyCommentId: Int?
    /// 回复评论名称（可空）
    let replyDisplayName: String?
    /// 评论内容
    let content: String
    /// 站点地址（可空）
    let site: String?
    /// 名称
    let displayName: String
    /// 邮箱
    let email: String
    /// 是否通过审核
    let isPass: Bool
    /// 子评论
    let children: [Comment]?
    /// 创建时间戳毫秒
    let createTime: Int64
}
