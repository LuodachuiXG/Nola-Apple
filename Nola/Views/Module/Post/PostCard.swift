//
//  PostCard.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation
import SwiftUI

/// 文章卡片
struct PostCard: View {
    
    let post: Post
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: .defaultSpacing) {
                
                HStack(alignment:.center, spacing: .defaultSpacing) {
                    // 文章状态指示器
                    PostStatusIndicatorView(post: post)
                    
                    if post.pinned {
                        // 文章置顶
                        Image(symbol: .pinned)
                            .resizable()
                            .rotationEffect(.degrees(45))
                            .frame(width: 10, height: 16)
                            .tint(.accentColor)
                    }
                    
                    if post.encrypted {
                        // 文章已加密
                        Image(symbol: .lock)
                            .resizable()
                            .frame(width: 10, height: 15)
                            .tint(.red)
                    }
                    
                    if post.visible == .HIDDEN {
                        // 文章不可见
                        Image(symbol: .hidden)
                            .resizable()
                            .frame(width: 18, height: 15)
                            .tint(PostVisible.HIDDEN.color)
                    }
                    
                    // 标题
                    Text(post.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .font(.headline)
                }
                
                // 摘要
                Text(post.excerpt)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.65))
                    .multilineTextAlignment(.leading)
                
                // 标签和分类
                if post.category != nil || !post.tags.isEmpty {
                    HStack {
                        if let category = post.category {
                            Text("&\(category.displayName)")
                        }
                        
                        
                        if post.tags.count >= 3 {
                            Text("#\(post.tags.first!.displayName) 等 \(post.tags.count) 个标签")
                        } else {
                            ForEach(post.tags, id: \.tagId) { tag in
                                Text("#\(tag.displayName)")
                            }
                        }
                    }
                    .font(.footnote)
                    .lineLimit(1)
                }
                
                // 创建时间和浏览量
                HStack {
                    Text("浏览量：\(post.visit)")
                    Spacer()
                    Text(post.createTime.formatMillisToDateStr())
                        
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(.defaultSpacing)
        }
    }
}

/// 文章状态指示器
private struct PostStatusIndicatorView: View {
    
    
    var post: Post
    
    // 标记当前动画是否已经启动，防止重复启动动画线程导致出现动画异常
    @State private var isAnimateStart = false
    
    // 用于控制圆点动画
    @State private var isOn = true
    
    
    var body: some View {
        ZStack {
            Circle()
//                .fill(isOn ? statusColor : statusColor.opacity(0))
                .fill(post.status.color)
                .frame(width: isOn ? 10 : 20, height: isOn ? 10 : 20)
            
            //            Circle()
            //                .fill(statusColor)
            //                .frame(width: 10, height: 10)
        }.onAppear {
            //            if !isAnimateStart {
            //                withAnimation(.easeInOut(duration: 1.5).delay(0.6).repeatForever(autoreverses: false)) {
            //                    isOn.toggle()
            //                }
            //                isAnimateStart = true
            //            }
        }
        .frame(maxWidth: 10, maxHeight: 10)
    }
}
