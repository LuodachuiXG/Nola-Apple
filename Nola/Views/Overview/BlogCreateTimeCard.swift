//
//  BlogCreateTimeCard.swift
//  Nola
//
//  Created by loac on 14/05/2025.
//

import Foundation
import SwiftUI

/// 博客创建时间卡片
struct BlogCreateTimeCard: View {
    
    // 创建时间戳（毫秒）
    var createTime: Int64
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("博客已建立")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
            Text("\(createTime.millisDaysSince()) 天")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.defaultSpacing)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
    }
}
