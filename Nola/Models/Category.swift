//
//  Category.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 分类实体类
struct Category: Codable, Equatable, Identifiable, Hashable {
    var id: Int { categoryId }
    
    /// 分类 ID
    let categoryId: Int
    /// 分类名
    var displayName: String
    /// 分类别名
    var slug: String
    /// 分类封面
    var cover: String?
    /// 是否统一封面
    var unifiedCover: Bool
    /// 文章数量
    let postCount: Int
}
