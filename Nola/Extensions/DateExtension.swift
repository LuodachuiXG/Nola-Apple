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
    
    /// 计算时间戳（毫秒）到现在过了多久（时间间隔）
    /// - returns: 返回间隔时间，单位：年、月、周、天、小时、分钟
    func timeAgoSince() -> String {
        let now = Date()
        let date = Date(timeIntervalSince1970: TimeInterval(self) / 1000)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute],
            from: date,
            to: now
        )
        
        if let years = components.year, years >= 1 {
            return "\(years) 年前"
        } else if let months = components.month, months >= 1 {
            return "\(months) 月前"
        } else if let weeks = components.weekOfYear, weeks >= 1 {
            return "\(weeks) 周前"
        } else if let days = components.day, days >= 1 {
            return "\(days) 天前"
        } else if let hours = components.hour, hours >= 1 {
            return "\(hours) 时前"
        } else if let minutes = components.minute, minutes >= 1 {
            return "\(minutes) 分前"
        } else {
            return "刚刚"
        }
    }
}
