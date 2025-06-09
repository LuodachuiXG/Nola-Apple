//
//  TencenOSS.swift
//  Nola
//
//  Created by loac on 04/06/2025.
//

import Foundation

/// 腾讯对象存储实体
struct TencenOSS: Codable {
    /// 密钥 ID
    var scretId: String
    /// 密钥 KEY
    var scretKey: String
    /// 存储区域
    var region: String
    /// 存储桶
    var bucket: String
    /// 是否使用 HTTPS
    var https: Bool
    /// 存储路径（可选）
    var path: String?
    
}
