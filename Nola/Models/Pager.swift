//
//  Pager.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation

/// 分页器实体类
struct Pager<T: Codable>: Codable {
    /// 当前页
    let page: Int
    /// 每页大小
    let size: Int
    /// 数据
    let data: T?
    /// 总数据
    let totalData: Int
    /// 总页数
    let totalPages: Int
}
