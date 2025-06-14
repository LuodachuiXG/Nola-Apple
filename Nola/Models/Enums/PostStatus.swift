//
//  PostStatus.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation
import SwiftUI

/// 文章状态枚举
enum PostStatus: String, Codable, Equatable, CaseIterable {
    /// 已发布
    case PUBLISHED
    /// 草稿
    case DRAFT
    /// 已删除
    case DELETED
    
    var desc: String {
        switch self {
        case .PUBLISHED:
            "已发布"
        case .DRAFT:
            "草稿"
        case .DELETED:
            "已删除"
        }
    }
    
    var color: Color {
        switch self {
        case .PUBLISHED:
                .green
        case .DRAFT:
                .yellow
        case .DELETED:
                .red
        }
    }
}
