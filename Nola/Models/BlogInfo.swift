//
//  BlogInfo.swift
//  Nola
//
//  Created by loac on 24/04/2025.
//

import Foundation

/// 博客信息实体类
/// - Parameters:
///   - title: 博客标题
///   - subtitle: 博客副标题
///   - blogger: 博主名
///   - logo: Logo
///   - favicon: Favicon
///   - createDate: 博客创建毫秒时间戳
struct BlogInfo: Codable {
    let title: String
    let subtitle: String?
    let blogger: String?
    let logo: String?
    let favicon: String?
    let createDate: Int64
}
