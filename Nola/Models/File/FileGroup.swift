//
//  FileGroup.swift
//  Nola
//
//  Created by loac on 04/06/2025.
//

import Foundation

/// 文件组实体
struct FileGroup: Codable {
    /// 文件组 ID
    let fileGroupId: Int
    /// 文件组名
    let displayName: String
    /// 文件组路径
    let path: String
    /// 文件组存储策略
    let storageMode: FileMode
}
