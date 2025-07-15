//
//  NetworkManager.swift
//  Nola
//
//  Created by loac on 23/03/2025.
//

import Foundation


enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}


class NetworkManager {
    static let shared = NetworkManager()
    
    private let timeoutInterval = 10.0
    
    private var baseUrl: String? = nil
    
    private let authManager = AuthManager.shared
    
    private let store = StoreManager.shared
    
    init() {
        // 尝试读取之前保存的 baseUrl
        baseUrl = store.getBaseUrl()
    }
    
    /// 获取服务器 URL
    func getBaseUrl() -> String? {
        return baseUrl
    }
    
    /// 设置服务器 URL
    /// - Parameters:
    ///   - url: 服务器 URL
    func setBaseUrl(url: String) {
        baseUrl = url
        store.setBaseUrl(baseUrl!)
    }
    
    /// 发起请求
    /// - Parameters:
    ///   - endpoint: 地址
    ///   - method: 请求方式
    ///   - parameters: 请求体
    ///   - array: 数组请求体，用于给一些只需要数组作为参数的接口使用。同时填写时 parameters 优先级更高
    func request<T: Codable>(
        endpoint: String,
        method: HttpMethod,
        parameters: [String: Any?]? = nil,
        array: [Any?]? = nil
    ) async throws -> ApiResponse<T>  {
        guard let base = baseUrl else {
            throw ApiError(message: "未配置服务器地址")
        }
        
        guard let url = URL(string: base + endpoint) else {
            throw ApiError(message: "无效的 URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeoutInterval
        
        // Token
        if let user = authManager.currentUser {
            request.setValue("Bearer \(user.token)", forHTTPHeaderField: "Authorization")
        }

        if let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } else if let array = array {
            request.httpBody = try JSONSerialization.data(withJSONObject: array)
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        let session = URLSession(configuration: config)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError(message: "非法响应")
        }
        
        guard let statusCode = ApiResponseStatusCode(rawValue: httpResponse.statusCode) else {
            throw ApiError(message: "请求错误码：\(httpResponse.statusCode)")
        }
        
        switch statusCode {
        case .conflict:
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: data)
            throw ApiError(message: apiResponse.errMsg ?? "未知错误")
        case .unauthorized:
            AuthManager.shared.logout()
            throw ApiError(message: "登录已过期")
        case .tooManyRequests:
            throw ApiError(message: "请求太频繁")
        case .internalServerError:
            throw ApiError(message: "服务器错误")
        case .ok:
            return try JSONDecoder().decode(ApiResponse<T>.self, from: data)
        }
    }
}
