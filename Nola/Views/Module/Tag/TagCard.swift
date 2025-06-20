//
//  TagCard.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI
import UIKit

/// 标签卡片
struct TagCard: View {
    
    var tag: Tag
    
    var body: some View {
        Card(padding: .defaultSpacing) {
            VStack(alignment: .leading, spacing: .defaultSpacing) {
                HStack(spacing: .defaultSpacing) {
                    Image(symbol: .tag)
                        .foregroundStyle(tag.color != nil ? Color(hex: tag.color!) : .primary)
                
                    Text(tag.displayName)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(String(tag.postCount))
                        .font(.callout)
                }
            }
            .frame(maxWidth: .infinity)
            .tint(.primary)
        }
    }
}
