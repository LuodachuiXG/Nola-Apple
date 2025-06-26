//
//  PostSort.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation

/// 评论排序枚举类
enum CommentSort: String, Codable, CaseIterable {
    /// 创建时间降序
    case CREATE_TIME_DESC
    /// 创建时间升序
    case CREATE_TIME_ASC
    
    
    var desc: String {
        switch self {
        case .CREATE_TIME_DESC:
            "创建时间降序"
        case .CREATE_TIME_ASC:
            "创建时间升序"
        }
    }
}
