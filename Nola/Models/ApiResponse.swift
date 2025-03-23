//
//  ApiResponse.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation

struct ApiResponse<T: Codable>: Codable {
    let code: StatusCode
    let errMsg: String?
    let data: T?
    
    enum StatusCode: Int, Codable {
        case ok = 200
        case conflict = 409
        case unauthorized = 401
        case tooManyRequests = 429
        case internalServerError = 500
    }
}
