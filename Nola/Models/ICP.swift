//
//  ICP.swift
//  Nola
//
//  Created by loac on 24/04/2025.
//

import Foundation

/// 备案信息实体类
/// - Parameters:
///   - icp: ICP 备案号
///   - public: 公网安备号
struct ICP: Codable {
    let icp: String?
    let `public`: String?
}
