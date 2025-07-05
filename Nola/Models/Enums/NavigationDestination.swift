//
//  NavigationDestination.swift
//  Nola
//
//  Created by loac on 2025/7/6.
//

import Foundation

/// 路由枚举
enum NavigationDestination: Hashable {
    /// 文章页面
    case post(postId: Int?)
    /// 标签页面
    case tag
    /// 分类页面
    case category
    /// 评论页面
    case comment
    /// 日志页面
    case diary
    /// 附件页面
    case file
    /// 链接页面
    case link
    /// 菜单页面
    case menu
}
