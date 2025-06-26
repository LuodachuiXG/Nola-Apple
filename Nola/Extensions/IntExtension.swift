//
//  IntExtension.swift
//  Nola
//
//  Created by loac on 2025/6/27.
//

import Foundation


extension Int {
    
    /// 设置最小值不小于 [minimumValue]
    func coerceAtLeast(minimumValue: Int) -> Int {
        self < minimumValue ? minimumValue : self
    }
    
    /// 设置最大值不大于 [maximumValue]
    func coerceAtMost(maximumValue: Int) -> Int {
        self > maximumValue ? maximumValue : self
    }
}
