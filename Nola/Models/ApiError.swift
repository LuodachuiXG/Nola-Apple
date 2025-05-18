//
//  ApiError.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation

/// API 接口报错异常
struct ApiError: Error, Codable {
    let message: String
}


