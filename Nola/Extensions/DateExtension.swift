//
//  DateExtension.swift
//  Nola
//
//  Created by loac on 12/04/2025.
//

import Foundation


extension Int64 {
    
    /// 将时间戳毫秒转为日期字符串
    func formatMillisToDateStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let interval = TimeInterval(self) / 1000
        let date = Date(timeIntervalSince1970: interval)
        return formatter.string(from: date)
    }
}
