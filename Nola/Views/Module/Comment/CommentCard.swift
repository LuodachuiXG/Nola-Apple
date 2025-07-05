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
    
    /// 文章内容，动态添加回复人等信息
    private var content: AttributedString {
        var text = AttributedString()
        
        if let name = comment.replyDisplayName {
            // 当前评论是回复别的评论
            var replyText = AttributedString("回复:\(name)  ")
            replyText.foregroundColor = .secondary
            text.append(replyText)
        }
        
        text.append(AttributedString(comment.content))
        return text
    }
    
    init(
        comment: Comment,
        onPostClick: @escaping (_ postId: Int) -> Void = { _ in }
    ) {
        self.comment = comment
        self.onPostClick = onPostClick
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: .defaultSpacing) {
                // 名称和 ID
                HStack(alignment: .center) {
                    
                    if !comment.isPass {
                        // 当前评论未通过审核
                        Image(symbol: .hidden)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18)
                            .foregroundStyle(Color(.systemRed))
                    }
                    
                    if let parent = comment.parentCommentId {
                        Text("#\(parent)")
                            .foregroundStyle(.secondary)
                    }
                    Text(comment.displayName)
                        .font(.headline)
                    Spacer()
                    Text("#\(comment.commentId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                  
                }
                .lineLimit(1)
                
                // 内容
                Text(content)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                
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
                
                // 创建时间
                Text(comment.createTime.formatMillisToDateStr())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                if !comment.isPass {
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
            .padding(.defaultSpacing)
            
        }
        .padding(.horizontal, .defaultSpacing)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .tint(.primary)
    }
}
