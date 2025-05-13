//
//  MostViewedPostCard.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation
import SwiftUI

/// 浏览最多的文章展示卡片
struct MostViewedPostCard: View {
    
    var post: Post
    
    private let feedbackGenerator = UIImpactFeedbackGenerator()
    
    var postCover: String? {
        if let cover = post.cover {
            return cover
        } else if let category = post.category, category.unifiedCover {
            return category.cover
        } else {
            return nil
        }
    }
    
    var caption: String {
        var str = "浏览量：\(post.visit)"
        if let category = post.category {
            str += "  &\(category.displayName)"
        }
        
        for tag in post.tags {
            str += "  #\(tag.displayName)"
        }
        
        return str
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let cover = postCover {
                AsyncImage(url: URL(string: cover)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                }.frame(maxHeight: 230)
            }
            
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(post.title)
                                .font(.title3)
                                .lineLimit(1)
                                .foregroundStyle(Color.white)
                                .shadow(radius: .defaultShadowRadius)
                        }
                        
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.6))
                            .lineLimit(1)
                            .shadow(radius: .defaultShadowRadius)
                        
                    }
                    Spacer()
                }
                .padding(.defaultSpacing)
                .background(.ultraThinMaterial)
                
            }.frame(maxHeight: 230)
        }
        .frame(maxWidth: .infinity, minHeight: 230)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .shadow(radius: .defaultShadowRadius)
        .onTapGesture {
            feedbackGenerator.impactOccurred()
        }
    }
}
