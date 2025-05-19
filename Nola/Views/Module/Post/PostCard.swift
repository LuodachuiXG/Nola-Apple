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
                // 标题
                Text(post.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .font(.title3.weight(.semibold))
                
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
