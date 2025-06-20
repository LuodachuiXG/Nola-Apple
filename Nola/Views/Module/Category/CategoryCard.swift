//
//  CategoryCard.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI
import UIKit
import SDWebImageSwiftUI

/// 分类卡片
struct CategoryCard: View {
    
    var category: Category
    
    init(category: Category) {
        self.category = category
        print(category)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let cover = category.cover, !cover.isEmpty, let url = URL(string: cover) {
                AnimatedImage(url: url) {
                    ProgressView()
                }
                .resizable()
                .scaledToFit()
            }
            
            HStack(spacing: .defaultSpacing) {
                Image(symbol: .category)
            
                Text(category.displayName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(String(category.postCount))
                    .font(.callout)
            }
            .padding(.defaultSpacing)
            .background(.ultraThinMaterial)
        }
        .frame(maxWidth: .infinity)
        .tint(.primary)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
}
