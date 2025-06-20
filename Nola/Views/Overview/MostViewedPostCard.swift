//
//  MostViewedPostCard.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import UIKit

/// 浏览最多的文章展示卡片
struct MostViewedPostCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var post: Post
    
    private let feedbackGenerator = UIImpactFeedbackGenerator()
    
    private var isLight: Bool {
        colorScheme == .light
    }
    
    private var textColor: Color {
        isLight ? .black : .white
    }
    
    // 底部说明文字
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
            if let cover = post.actualCover {
                AnimatedImage(url: URL(string: cover)) {
                    VStack(alignment: .center) {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                }
                .resizable()
                
                .scaledToFill()
                
            }
            
            VStack {
                
                if post.actualCover != nil {
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(post.title)
                                .font(.title3)
                                .lineLimit(1)
                                .foregroundStyle(post.actualCover == nil ? Color.primary : textColor)
                                .shadow(radius: post.actualCover == nil ? 0 : .defaultShadowRadius)
                        }
                        
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(post.actualCover == nil ? Color.secondary : textColor)
                            .lineLimit(1)
                            .shadow(radius: post.actualCover == nil ? 0 : .defaultShadowRadius)
                        
                    }
                    Spacer()
                }
                .padding(.defaultSpacing)
                .background(.ultraThinMaterial)
                
            }
        }
//        .frame(maxWidth: .infinity, minHeight: postCover == nil ? 52 : 230)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .shadow(radius: post.actualCover == nil ? 0 : .defaultShadowRadius)
        .onTapGesture {
            feedbackGenerator.impactOccurred()
        }
    }
}
