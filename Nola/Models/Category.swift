//
//  Category.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 分类实体类
struct Category: Codable {
    /// 分类 ID
    let categoryId: Int
    /// 分类名
    let displayName: String
    /// 分类别名
    let slug: String
    /// 分类封面
    let cover: String?
    /// 是否统一封面
    let unifiedCover: Bool
    /// 文章数量
    let postCount: Int
}
