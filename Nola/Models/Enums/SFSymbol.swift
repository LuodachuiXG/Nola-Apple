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
    /// 日记
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
    
    /// 播放（预览文章）
    case play = "play"
    
    /// 列表
    case list = "list.bullet"
    
    /// 添加
    case plus = "plus"
    
    /// X
    case x = "xmark"
    
    /// 过滤
    case filter = "line.3.horizontal.decrease"
    
    /// 搜索
    case search = "magnifyingglass"
    
    /// 字符
    case character = "character"
    
    /// 信息
    case info = "info.circle"
    
    /// 垃圾桶
    case trash = "trash"
    
    /// 地球图标
    case globe = "globe"
    
    /// 编辑
    case edit = "pencil"
    
    /// 返回
    case returnIcon = "return"
    
    /// 回复
    case reply = "arrowshape.turn.up.left"
}
