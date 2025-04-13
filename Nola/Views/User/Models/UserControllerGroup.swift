//
//  UserControllerItem.swift
//  Nola
//
//  Created by loac on 12/04/2025.
//

import Foundation
import SwiftUI


/// 用户控制项组实体类
/// - Parameters:
///   - name: 组名
///   - items: 项数组
struct UserControllerGroup: Identifiable {
    let id = UUID()
    let name: String
    let items: [UserControllerItem]
    
    init(name: String, items: [UserControllerItem]) {
        self.name = name
        self.items = items
    }
}


/// 用户控制项实体类
/// - Parameters:
///   - icon: 图标
///   - name: 项名
///   - destination: 目的地
struct UserControllerItem: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let destination: AnyView?
    let onClick: () -> Void
    
    init(icon: String, name: String, destination: some View) {
        self.icon = icon
        self.name = name
        self.destination = AnyView(destination)
        self.onClick = {}
    }
    
    init(icon: String, name: String, onClick: @escaping () -> Void) {
        self.icon = icon
        self.name = name
        self.destination = nil
        self.onClick = onClick
    }
}
