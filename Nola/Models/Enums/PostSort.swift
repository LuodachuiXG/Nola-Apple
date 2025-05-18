//
//  PostSort.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation

/// 文章排序枚举类
enum PostSort: String, Codable {
    /// 创建时间降序
    case CREATE_DESC
    /// 创建时间升序
    case CREATE_ASC
    /// 修改时间降序
    case MODIFY_DESC
    /// 修改时间升序
    case MODIFY_ASC
    /// 浏览量降序
    case VISIT_DESC
    /// 浏览量升序
    case VISIT_ASC
}
