//
//  Diary.swift
//  Nola
//
//  Created by loac on 2025/7/14.
//

import Foundation


/// 日记实体
struct Diary: Codable, Hashable {
    /// 日记 ID
    let diaryId: Int
    /// 日记内容
    var content: String
    /// 日记 HTML
    let html: String
    /// 创建时间戳
    let createTime: Int64
    /// 最后修改时间戳
    let lastModifyTime: Int64?

}
