//
//  CommentCard.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI
import UIKit
import SDWebImageSwiftUI

/// 评论卡片
struct CommentCard: View {
    
    /// 评论实体
    var comment: Comment
    
    /// 文章标题点击事件
    var onPostClick: (_ postId: Int) -> Void
    
    /// 通过审核按钮点击事件
    var onPassClick: () -> Void
    
    /// 站点地址点击事件
    var onSiteClick: (_ side: String) -> Void
    
    /// 文章内容，动态添加回复人等信息
    private var content: AttributedString {
        var text = AttributedString()
        
        if let name = comment.replyDisplayName {
            // 当前评论是回复别的评论
            var replyText = AttributedString("回复 \(name): ")
            replyText.foregroundColor = .secondary
            text.append(replyText)
        }
        
        text.append(AttributedString(comment.content))
        return text
    }
    
    // 是否显示评论详细信息
    @State private var showDetail = false
    
    /// Init
    /// - Parameters:
    ///   - comment: 评论实体
    ///   - onPostClick: 文章点击事件
    ///   - onPassClick: 通过审核点击事件
    ///   - onSiteClick: 站点地址点击事件
    init(
        comment: Comment,
        onPostClick: @escaping (_ postId: Int) -> Void = { _ in },
        onPassClick: @escaping () -> Void = {},
        onSiteClick: @escaping (_ site: String) -> Void = { _ in }
    ) {
        self.comment = comment
        self.onPostClick = onPostClick
        self.onPassClick = onPassClick
        self.onSiteClick = onSiteClick
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: .defaultSpacing) {
                // 名称和 ID
                HStack(alignment: .center) {
                    
                    if !comment.isPass {
                        // 当前评论未通过审核
                        ZStack {
                            Text("待审核")
                                .foregroundStyle(.white)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(2)
                        .background(Color(UIColor.systemRed))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    // 当前评论的父评论
                    if let parent = comment.parentCommentId {
                        Text("#\(parent)")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 名称
                    Text(comment.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    // 楼层号
                    Text("#\(comment.commentId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                  
                }
                .lineLimit(1)
                
                // 邮箱地址
                if showDetail {
                    Text(comment.email)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .textSelection(.enabled)
                }
                
                // 内容
                Text(content)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(showDetail ? Int.max : 3)
                    .textSelection(.enabled)
                
                // 评论更多详细信息
                if showDetail {
                    
                    // 文章标题
                    if let title = comment.postTitle {
                        HStack {
                            Image(symbol: .post)
                            Text(title)
                        }
                        .font(.footnote)
                        .foregroundStyle(Color(.systemBlue))
                        .lineLimit(1)
                        .onTapGesture {
                            onPostClick(comment.postId)
                        }
                    }
                    
                    // 站点地址
                    if let site = comment.site {
                        HStack {
                            Image(symbol: .globe)
                            
                            // 如果站点地址为 /，则代表是当前主站
                            Text(site == "/" ? "博客主站" : site)
                                .textSelection(.enabled)
                        }
                        .font(.footnote)
                        .foregroundStyle(site == "/" ? .secondary : Color(.systemBlue))
                        .lineLimit(1)
                        .onTapGesture {
                            // 如果当前站点地址是主站，则不跳转网页
                            if site != "/" {
                                onSiteClick(site)
                            }
                        }
                    }
                }
                
                // 创建时间
                Text(comment.createTime.formatMillisToDateStr())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                if !comment.isPass {
                    Button {
                        onPassClick()
                    } label: {
                        HStack {
                            Image(symbol: .check)
                            Text("通过审核")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(.secondary)
                        .font(.callout)
                        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
                    }

                }
                
            }
            .padding(.defaultSpacing)
        }
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .tint(.primary)
        .onTapGesture {
            withAnimation {
                showDetail.toggle()
            }
        }
    }
}
