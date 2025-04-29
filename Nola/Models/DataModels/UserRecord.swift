//
//  UserRecord.swift
//  Nola
//
//  Created by loac on 28/04/2025.
//

import Foundation
import CoreData

/// 用户登录记录
@objc(UserRecord)
final class UserRecord: NSManagedObject {
    @NSManaged
    var id: UUID
    
    // 站点地址
    @NSManaged
    var url: String
    
    // 用户名
    @NSManaged
    var username: String
    
    // 昵称
    @NSManaged
    var displayName: String
    
    // 头像
    @NSManaged
    var avatar: String
    
    // 最后登录时间
    @NSManaged
    var lastLoginTime: Date
}
