//
//  NetworkManager.swift
//  Nola
//
//  Created by loac on 23/03/2025.
//

import Foundation
import Combine

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}


class NetworkManager {
    static let shared = NetworkManager()
    private var baseUrl = "https://console.loac.cc"
    
    func request<T: Codable>(
        endpoint: String,
        method: HttpMethod,
        parameters: [String: Any]? = nil
    ) -> AnyPublisher<ApiResponse<T>, ApiError>  {
        let url = URL(string: baseUrl + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ApiError(message: "非法响应")
                }
                
                guard let httpStatus = ApiResponse<T>.StatusCode(rawValue: httpResponse.statusCode) else {
                    throw ApiError(message: "未知 HTTP 状态码")
                }
                
                switch httpStatus {
                case .conflict:
                    let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: data)
                    throw ApiError(message: apiResponse.errMsg ?? "未知错误")
                case .unauthorized:
                    throw ApiError(message: "登录已过期")
                case .tooManyRequests:
                    throw ApiError(message: "请求太频繁")
                case .internalServerError:
                    throw ApiError(message: "服务器错误")
                case .ok:
                    return data
                }
            }
            .decode(type: ApiResponse<T>.self, decoder: JSONDecoder())
            .mapError { error -> ApiError in
                if let apiError = error as? ApiError {
                    return apiError
                }
                return ApiError(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
