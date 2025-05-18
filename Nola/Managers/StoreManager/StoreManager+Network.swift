//
//  StoreManager+Network.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation


/// 网络相关 StoreManager
extension StoreManager {
    
    /// 获取基地址
    func getBaseUrl() -> String? {
        return string(.baseUrl)
    }
    
    /// 设置基地址
    func setBaseUrl(_ url: String) {
        set(.baseUrl, url)
    }
}
