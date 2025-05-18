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
    
    // 文章封面
    var cover: String? {
        if let cover = post.cover {
            return cover
        }
        
        if let category = post.category, let cover = category.cover, category.unifiedCover {
            // 当前文章的分类设置了统一封面
            return cover
        }
        
        return nil
    }
    
    var body: some View {
        Card {
            VStack {
                if let cover {
                    AsyncImage(url: URL(string: cover)) { img in
                        img
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .frame(maxHeight: 180)
                    .clipped()
                }
                
                Text(post.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title3.weight(.semibold))
                    .padding(.defaultSpacing)
                    .padding(.bottom, .defaultSpacing / 2)
            }
        }
        
    }
}
