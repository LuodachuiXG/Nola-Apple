//
//  SFSymbol.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation

/// 图表符号枚举
enum SFSymbol: String {
    /// 文章
    case post = "book"
    /// 分类
    case category = "books.vertical"
    /// 标签
    case tag = "tag"
    /// 评论
    case comment = "message"
    /// 日常
    case diary = "leaf"
    /// 附件
    case file = "tray.full"
    /// 链接
    case link = "at"
    /// 菜单
    case menu = "line.3.horizontal"
    
    
    /// 管理员 - 圆形
    case adminCircle = "person.circle"
    /// 设置 - 圆形
    case settingCircle = "gear.circle"
    /// 备份 - 圆形
    case backupCircle = "arrow.clockwise.circle"
    
    /// 可点击右箭头
    case clickableArrowRight = "chevron.right"
    
    /// 对勾
    case check = "checkmark"
    
    /// 引用
    case quote = "text.quote"
    
    /// 锁
    case lock = "lock.fill"
    
    /// 隐藏
    case hidden = "eye.slash"
    
    /// 置顶
    case pinned = "pin.fill"
    
    /// 保存
    case save = "square.and.arrow.down"
}
