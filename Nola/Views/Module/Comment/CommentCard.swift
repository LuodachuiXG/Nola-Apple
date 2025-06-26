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
                // 名称
                Text(comment.displayName)
                    .font(.headline)
                
                // 内容
                Text(comment.content)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
                
                // 创建时间
                Text(comment.createTime.formatMillisToDateStr())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            }
            .padding(.defaultSpacing)
            
        }
        .padding(.horizontal, .defaultSpacing)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .tint(.primary)
    }
}
