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
                            .tint(.brown)
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
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                // 标签和分类
                if post.category != nil || !post.tags.isEmpty {
                    HStack(spacing: .defaultSpacing) {
                        if let category = post.category {
                            Text("&\(category.displayName)")
                        }
                        
                        ForEach(post.tags, id: \.tagId) { tag in
                            Text("#\(tag.displayName)")
                        }
                    }
                    .font(.footnote)
                }
            }
            .padding(.defaultSpacing)
        }
    }
}

/// 文章状态指示器
private struct PostStatusIndicatorView: View {
    
    
    var post: Post
    
    // 指示器颜色
    var statusColor: Color {
        switch post.status {
        case .PUBLISHED:
                .green
        case .DRAFT:
                .yellow
        case .DELETE:
                .red
        }
    }
    
    @State private var isOn = true
    
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isOn ? statusColor : statusColor.opacity(0))
                .frame(width: isOn ? 10 : 20, height: isOn ? 10 : 20)
            
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
        }.onAppear {
            withAnimation(.easeInOut(duration: 1.5).delay(0.6).repeatForever(autoreverses: false)) {
                isOn.toggle()
            }
        }
        .frame(maxWidth: 10, maxHeight: 10)
    }
}
