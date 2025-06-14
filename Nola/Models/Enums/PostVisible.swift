//
//  PostVisible.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation
import SwiftUI

/// 文章可见性枚举
enum PostVisible: String, Codable, Equatable, CaseIterable {
    case VISIBLE
    case HIDDEN
    
    var desc: String {
        switch self {
        case .VISIBLE:
            "可见"
        case .HIDDEN:
            "隐藏"
        }
    }
    
    var color: Color {
        switch self {
        case .VISIBLE:
                .green
        case .HIDDEN:
                .brown
        }
    }
}
