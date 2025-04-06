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
}

