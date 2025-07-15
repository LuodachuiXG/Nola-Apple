//
//  DiaryCard.swift
//  Nola
//
//  Created by loac on 2025/7/15.
//

import Foundation
import SwiftUI

/// 日记卡片
struct DiaryCard: View {
    
    var diary: Diary
    
    init(diary: Diary) {
        self.diary = diary
    }
    
    var body: some View {
        Card(alignment: .leading, padding: .defaultSpacing) {
            VStack(spacing: .defaultSpacing) {
                Text(diary.createTime.chineseMonth())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                Text(diary.content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                
                // 创建时间
                HStack(alignment: .bottom) {
                    Text(diary.createTime.formatMillisToDateStr())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
}
