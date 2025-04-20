//
//  File.swift
//  Nola
//
//  Created by loac on 20/04/2025.
//

import Foundation


/// 获取实际 URL 地址，将相对地址转为绝对地址（在当前已经保存了服务器地址的前提下）
/// - Parameters:
///   - url: 待转换的 URL 地址
func getActualUrl(url: String) -> String {
    if url.isEmpty {
        return url
    }
    
    if let baseUrl = NetworkManager.shared.getBaseUrl() {
        if url.contains("http") {
            // 当前已经是绝对地址
            return url
        } else {
            // 当前不是绝对地址，拼接
            return baseUrl + (url.starts(with: "/") ? url : "/\(url)")
        }
    } else {
        // 当前没有保存服务器基地址，返回 url
        return url
    }
}
