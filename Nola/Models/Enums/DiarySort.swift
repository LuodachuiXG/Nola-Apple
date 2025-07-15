//
//  DiarySort.swift
//  Nola
//
//  Created by loac on 2025/7/14.
//

import Foundation


/// 日记排序枚举类
enum  DiarySort: String, Codable, CaseIterable {
    /// 创建时间降序
    case CREATE_TIME_DESC
    /// 创建时间升序
    case CREATE_TIME_ASC
    /// 修改时间降序
    case MODIFY_TIME_DESC
    /// 修改时间升序
    case MODIFY_TIME_ASC
    
    var desc: String {
        switch self {
        case .CREATE_TIME_DESC:
            "创建时间降序"
        case .CREATE_TIME_ASC:
            "创建时间升序"
        case .MODIFY_TIME_DESC:
            "修改时间降序"
        case .MODIFY_TIME_ASC:
            "修改时间升序"
        }
    }
}
