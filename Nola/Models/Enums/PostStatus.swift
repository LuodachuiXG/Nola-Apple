//
//  PostStatus.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 文章状态枚举
enum PostStatus: String, Codable {
    /// 已发布
    case PUBLISHED
    /// 草稿
    case DRAFT
    /// 已删除
    case DELETE
}
