//
//  Tag.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 标签实体类
struct Tag: Codable, Equatable {
    /// 标签 ID
    let tagId: Int
    /// 标签名
    let displayName: String
    /// 标签别名
    let slug: String
    /// 标签颜色（#FF0000）
    let color: String?
    /// 文章数量
    let postCount: Int
}
