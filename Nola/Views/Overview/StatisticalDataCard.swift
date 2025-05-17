//
//  StatisticalDataCard.swift
//  Nola
//
//  Created by loac on 14/05/2025.
//

import Foundation
import SwiftUI

/// 统计数据卡片
struct StatisticalDataCard: View {
    
    // 标题
    var title: String
    
    // 内容
    var content: String
    
    var body: some View {
        Card(alignment: .leading, padding: .defaultSpacing) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
            Text(content)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
