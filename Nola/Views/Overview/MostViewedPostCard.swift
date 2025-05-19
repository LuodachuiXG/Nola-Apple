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
        var cover: String? = nil
        if let c = post.cover {
            cover = c
        } else if let category = post.category, category.unifiedCover {
            cover = category.cover
        }
        
        if let c = cover, !c.isEmpty {
            return c
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
                
                if postCover != nil {
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(post.title)
                                .font(.title3)
                                .lineLimit(1)
                                .foregroundStyle(postCover == nil ? Color.primary : Color.white)
                                .shadow(radius: postCover == nil ? 0 : .defaultShadowRadius)
                        }
                        
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(postCover == nil ? Color.secondary : Color.white)
                            .lineLimit(1)
                            .shadow(radius: postCover == nil ? 0 : .defaultShadowRadius)
                        
                    }
                    Spacer()
                }
                .padding(.defaultSpacing)
                .background(.ultraThinMaterial)
                
            }.frame(maxHeight: postCover == nil ? 52 : 230)
        }
        .frame(maxWidth: .infinity, minHeight: postCover == nil ? 52 : 230)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .shadow(radius: postCover == nil ? 0 : .defaultShadowRadius)
        .transition(.scale)
        .onTapGesture {
            feedbackGenerator.impactOccurred()
        }
    }
}
