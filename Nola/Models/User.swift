//
//  User.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation

struct User: Codable {
    let username: String
    let email: String
    let displayName: String
    let description: String?
    let createDate: Int64
    let lastLoginDate: Int64?
    let avatar: String?
    let token: String
}
