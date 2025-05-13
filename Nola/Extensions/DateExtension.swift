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
    
    
    /// 计算时间戳到今天已经有多少天了
    /// - returns: 返回天数
    func millisDaysSince() -> Int {
        let date = Date(timeIntervalSince1970: TimeInterval(self) / 1000)
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days
    }
}
