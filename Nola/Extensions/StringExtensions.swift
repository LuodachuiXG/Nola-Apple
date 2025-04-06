//
//  StringExtensions.swift
//  Nola
//
//  Created by loac on 06/04/2025.
//

import Foundation

extension String {
    
    /// 验证一段字符串是否是正确的 URL
    /// 支持 http/https 以及 IP 的形式
    func isValidUrl() -> Bool {
        guard let url = URL(string: self),
              let scheme = url.scheme,
              let host = url.host else {
            return false
        }
        
        // 验证协议
        guard ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        
        // 验证域名或IP
        let hostPattern = "(([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]{2,}|(([0-9]{1,3}\\.){3}[0-9]{1,3}))"
        guard let _ = host.range(of: hostPattern, options: .regularExpression) else {
            return false
        }
        
        // 可选：验证IP地址范围（0-255）
        if host.range(of: "^([0-9]{1,3}\\.){3}[0-9]{1,3}$", options: .regularExpression) != nil {
            let octets = host.components(separatedBy: ".")
            for octet in octets {
                guard let num = Int(octet), num >= 0, num <= 255 else {
                    return false
                }
            }
        }
        
        return true
    }
}
