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
    
    var comment: Comment
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: .defaultSpacing) {
                // 名称和邮箱
                HStack(alignment: .top) {
                    Text(comment.displayName)
                        .font(.headline)
                    Spacer()
                    Text(comment.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                  
                }
                .lineLimit(1)
                
                // 内容
                Text(comment.content)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                
                // 文章标题
                if let title = comment.postTitle {
                    NavigationLink(value: comment.postId) {
                        HStack {
                            Image(symbol: .post)
                            Text(title)
                        }
                        .font(.footnote)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                    }
                }
                
                // 创建时间
                Text(comment.createTime.formatMillisToDateStr())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
            }
            .padding(.defaultSpacing)
            
        }
        .padding(.horizontal, .defaultSpacing)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .tint(.primary)
    }
}
