//
//  TagCard.swift
//  Nola
//
//  Created by loac on 18/05/2025.
//

import Foundation
import SwiftUI


/// 概览页面标签卡片
struct OverviewTagCard: View {
    
    var tag: Tag
    
    var body: some View {
        HStack {
            Image(symbol: .tag)
            Text("\(tag.displayName) （\(tag.postCount)）")
                .lineLimit(1)
            Spacer()
            Image(symbol: .clickableArrowRight)
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
