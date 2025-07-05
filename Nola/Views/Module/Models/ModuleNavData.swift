//
//  ModuleNavButton.swift
//  Nola
//
//  Created by loac on 19/03/2025.
//

import Foundation
import SwiftUI


/// 模块页面导航实体类
/// - Parameters:
///   - id: ID.
///   - title: 导航名字.
///   - icon: 导航图标.
///   - count 数量，默认 -1 不显示
///   - destination: 导航目的地.
struct ModuleNavData: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let count: Int?
    let destination: NavigationDestination
    
    init(title: String, icon: String, destination: NavigationDestination, count: Int?) {
        self.title = title
        self.icon = icon
        self.count = count
        self.destination = destination
    }
}
