//
//  BoolExtension.swift
//  Nola
//
//  Created by loac on 20/04/2025.
//

import Foundation
import SwiftUI

extension Binding<Bool> {
    /// 改变当前 bool 的值后延迟多少秒后恢复
    /// - Parameters:
    ///   - duration: 延迟恢复时间
    ///   - animate: 是否有动画（默认 true）
    func toggleDuration(duration: Double = 1.0, animate: Bool = true) {
        if animate {
            withAnimation {
                self.wrappedValue.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation {
                    self.wrappedValue.toggle()
                }
            }
        } else {
            self.wrappedValue.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.wrappedValue.toggle()
            }
        }
    }
}
