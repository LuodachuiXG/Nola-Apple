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
public class UserRecord: NSManagedObject {
    @NSManaged
    public var id: UUID
    
    // 站点地址
    @NSManaged
    public var url: String
    
    // 用户名
    @NSManaged
    public var username: String
    
    // 昵称
    @NSManaged
    public var displayName: String
    
    // 头像
    @NSManaged
    public var avatar: String
    
    // 最后登录时间
    @NSManaged
    public var lastLoginTime: Date

}
