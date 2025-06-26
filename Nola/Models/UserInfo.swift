//
//  UserInfo.swift
//  Nola
//
//  Created by loac on 20/04/2025.
//

import Foundation

/// 用户信息实体类
struct UserInfo: Codable {
    let userId: Int
    var username: String
    var email: String
    var displayName: String
    var description: String?
    let avatar: String?
    let createDate: Int64
    let lastLoginDate: Int64?
}
