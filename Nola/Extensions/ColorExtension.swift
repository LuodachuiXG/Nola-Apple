//
//  ColorExtension.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI

extension Color {
    
    /// 从十六进制字符串初始化 SwiftUI Color
    /// - 支持格式: "#RRGGBB", "RRGGBB", "#AARRGGBB", "AARRGGBB", "RGB"
    init(hex: String) {
        var hex = hex.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgbValue) else {
            self = .black
            return
        }
        
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        
        switch hex.count {
        case 3:  // RGB (4bit per component)
            red = Double((rgbValue >> 8) & 0xF) / 15.0
            green = Double((rgbValue >> 4) & 0xF) / 15.0
            blue = Double(rgbValue & 0xF) / 15.0
            alpha = 1.0
            
        case 6:  // RRGGBB (8bit per component)
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
            alpha = 1.0
            
        case 8:  // AARRGGBB
            alpha = Double((rgbValue >> 24) & 0xFF) / 255.0
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
            
        default:
            self = .black
            return
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    /// 将 Color 转为十六进制字符串（自动输出 #RRGGBB 或 #RRGGBBAA）
    func toHex() -> String? {
        let uiColor = UIColor(self)
        
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB),
              let converted = uiColor.cgColor.converted(to: sRGB, intent: .defaultIntent, options: nil),
              let components = converted.components
        else {
            return nil
        }
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
        
        switch components.count {
        case 4:
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
        case 2:
            // 灰度 + alpha（monochrome）
            red = components[0]
            green = components[0]
            blue = components[0]
            alpha = components[1]
        default:
            return nil
        }
        
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        let a = Int(round(alpha * 255))
        
        if a < 255 {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}
