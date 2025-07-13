//
//  FilterIndicatorContainer.swift
//  Nola
//
//  Created by loac on 2025/7/13.
//

import Foundation
import SwiftUI


/// 过滤指示器容器
struct FilterIndicatorContainer: View {
    
    // 标题
    private var title: String
    // 内容
    private var content: String
    // 文本颜色
    private var color: Color
    
    // 清除按钮点击事件
    private var onClear: () -> Void = {}
    
    /// Init
    /// - Parameters:
    ///   - title: 标题（如：文章状态）
    ///   - content: 内容（如：已发布）
    ///   - color: 内容文本颜色
    ///   - onClear: 清除按钮点击事件
    init(title: String, content: String, color: Color, onClear: @escaping () -> Void) {
        self.title = title
        self.content = content
        self.color = color
        self.onClear = onClear
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
            Text(content)
                .font(.callout.weight(.semibold))
                .foregroundStyle(color)
            Spacer()
            Button {
                onClear()
            } label: {
                Label("清除", systemImage: SFSymbol.x.rawValue)
            }
        }
        .padding(.defaultSpacing)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .shadow(color: .black.opacity(0.2), radius: 10)
    }
}
