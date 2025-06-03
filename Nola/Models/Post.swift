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
    var title: String
    /// 是否自动生成摘要
    var autoGenerateExcerpt: Bool
    /// 文章摘要
    var excerpt: String
    /// 文章别名
    var slug: String
    /// 文章封面
    var cover: String?
    /// 是否允许评论
    var allowComment: Bool
    /// 是否置顶
    var pinned: Bool
    /// 文章状态
    var status: PostStatus
    /// 文章可见性
    var visible: PostVisible
    /// 文章是否有密码
    var encrypted: Bool
    /// 文章密码（始终为 null，密码不会返回）
    var password: String?
    /// 访问量
    let visit: Int
    /// 文章分类
    var category: Category?
    /// 文章标签
    var tags: [Tag]
    /// 文章创建时间戳（毫秒）
    let createTime: Int64
    /// 文章最后修改时间戳（毫秒）
    let lastModifyTime: Int64?
}


extension Post {
    
    /// 文章的实际封面，如果文章本身有封面则返回本身的封面，否则返回分类的封面（分类设置了统一封面）
    var actualCover: String? {
        if let cover = cover, !cover.isEmpty {
            return cover
        } else if let categoryCover = category?.cover, category?.unifiedCover == true && !categoryCover.isEmpty {
            return categoryCover
        } else {
            return nil
        }
    }
}
