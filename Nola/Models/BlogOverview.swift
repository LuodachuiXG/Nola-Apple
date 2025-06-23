//
//  BlogOverview.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation

/// 博客概览实体类
struct BlogOverview: Codable {
    /// 项目数量
    let count: BlogOverviewCount
    /// 所有标签
    var tags: [Tag]
    /// 所有分类
    var categories: [Category]
    /// 浏览量最高的文章
    let mostViewedPost: Post?
    /// 最后一次操作日志
    let lastOperation: String?
    /// 最后登录时间戳（毫秒）
    let lastLoginDate: Int64?
    /// 博客创建时间戳（毫秒）
    let createDate: Int64?
    
    /// 默认值初始化
    init() {
        self.count = .init(post: 10, tag: 20,category: 30, comment: 40, diary: 50, file: 60,link: 70, menu: 80)
        self.tags = []
        self.categories = []
        self.mostViewedPost = nil
        self.lastOperation = nil
        self.lastLoginDate = nil
        self.createDate = nil
        
    }
}


/// 博客概览项目数量实体类
struct BlogOverviewCount: Codable {
    let post: Int
    let tag: Int
    let category: Int
    let comment: Int
    let diary: Int
    let file: Int
    let link: Int
    let menu: Int
}
