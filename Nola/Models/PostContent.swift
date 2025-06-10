//
//  PostContent.swift
//  Nola
//
//  Created by loac on 09/06/2025.
//

import Foundation

struct PostContent: Codable {
    /// 文章内容 ID
    var postContentId: Int
    /// 文章 ID
    var postId: Int
    /// 文章内容
    var content: String
    /// 文章 HTML
    var html: String
    /// 文章内容状态（PUBLISHED, DRAFT）
    var status: PostStatus
    /// 草稿名（获取的文章正文时，草稿名始终为 null）
    var draftName: String?
    /// 文章内容最后修改时间戳
    var lastModifyTime: Int64
}
