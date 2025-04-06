//
//  StatusCode.swift
//  Nola
//
//  Created by loac on 06/04/2025.
//

import Foundation

enum StatusCode: Int, Codable {
    case ok = 200
    case conflict = 409
    case unauthorized = 401
    case tooManyRequests = 429
    case internalServerError = 500
}
