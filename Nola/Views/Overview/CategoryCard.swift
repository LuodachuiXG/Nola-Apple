//
//  CategoryCard.swift
//  Nola
//
//  Created by loac on 18/05/2025.
//

import Foundation
import SwiftUI


/// 分类卡片
struct CategoryCard: View {
    
    var category: BlogOverviewCategory
    
    var body: some View {
        HStack {
            Image(systemName: "books.vertical")
            Text("\(category.displayName) （\(category.postCount)）")
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.defaultSpacing)
        .background(Color(.systemBlue))
        .foregroundStyle(.white)
        .fontWeight(.semibold)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
}
