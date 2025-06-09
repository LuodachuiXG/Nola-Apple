//
//  FileMode.swift
//  Nola
//
//  Created by loac on 04/06/2025.
//

import Foundation

/// 文件存储策略枚举类
enum FileMode: String, Codable {
    /// 本地存储
    case LOCAL
    /// 腾讯云对象存储
    case TENCENT_COS
}
