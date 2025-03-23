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
            print(parameters)
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ApiError(message: "Invalid response.")
                }
                
                print(httpResponse.statusCode)
                
                guard let httpStatus = ApiResponse<T>.StatusCode(rawValue: httpResponse.statusCode) else {
                    throw ApiError(message: "Unknown http status code.")
                }
                
                switch httpStatus {
                case .conflict:
                    let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: data)
                    throw ApiError(message: apiResponse.errMsg ?? "Unknown reponse error.")
                case .unauthorized:
                    throw ApiError(message: "Login has expired.")
                case .tooManyRequests:
                    throw ApiError(message: "Request too frequently.")
                case .internalServerError:
                    throw ApiError(message: "Server Error.")
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
