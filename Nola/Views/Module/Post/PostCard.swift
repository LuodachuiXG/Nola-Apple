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
    
    let click: () -> Void
    
    init(post: Post, click: @escaping () -> Void = {}) {
        self.post = post
        self.click = click
    }

    var body: some View {
        Button {
            click()
        } label: {
            Card {
                LazyVStack(alignment: .leading, spacing: .defaultSpacing) {
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
                    
                }
                .padding(.defaultSpacing)
            }
        }
        .tint(.primary)
    }
}
