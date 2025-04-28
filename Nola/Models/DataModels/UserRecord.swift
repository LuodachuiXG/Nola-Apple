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
    
    // 密码
    @NSManaged
    var password: String
    
    // 创建时间
    @NSManaged
    var createTime: Date
}
