//
//  Post.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 文章实体类
struct Post: Codable, Equatable {
    /// 文章 ID
    let postId: Int
    /// 文章标题
    let title: String
    /// 是否自动生成摘要
    let autoGenerateExcerpt: Bool
    /// 文章摘要
    let excerpt: String
    /// 文章别名
    let slug: String
    /// 文章封面
    let cover: String?
    /// 是否允许评论
    let allowComment: Bool
    /// 是否置顶
    let pinned: Bool
    /// 文章状态
    let status: PostStatus
    /// 文章可见性
    let visible: PostVisible
    /// 文章是否有密码
    let encrypted: Bool
    /// 文章密码
    let password: String?
    /// 访问量
    let visit: Int
    /// 文章分类
    let category: Category?
    /// 文章标签
    let tags: [Tag]
    /// 文章创建时间戳（毫秒）
    let createTime: Int64
    /// 文章最后修改时间戳（毫秒）
    let lastModifyTime: Int64?
}
