//
//  NolaFile.swift
//  Nola
//
//  Created by loac on 04/06/2025.
//

import Foundation

/// Nola 文件实体
struct NolaFile: Hashable, Codable {
    /// 文件 ID
    var fileId: Int64
    /// 文件组 ID
    var fileGroupId: Int64?
    /// 文件组名
    var fileGroupName: String?
    /// 文件名
    var displayName: String
    /// 文件地址（本地存储为相对地址，其他存储方式为绝对地址）
    var url: String
    /// 文件大小（字节 Bytes）
    var size: Int64
    /// 文件存储策略
    var storageMode: FileMode
    /// 文件上传时间
    var createTime: Int64
}
