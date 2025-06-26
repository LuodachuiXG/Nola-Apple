//
//  UserAvatar.swift
//  Nola
//
//  Created by loac on 25/03/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserAvatar: View {
    
    // 用户昵称
    var displayName: String
    
    // 用户头像
    var avatar: String? = nil
    
    // 头像宽度
    var width: CGFloat = 80
    
    @Environment(\.colorScheme) private var colorScheme
    private var isLight: Bool {
        colorScheme == .light
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if avatar != nil, !avatar!.isEmpty, let url = URL(string: avatar!) {
                AnimatedImage(url: url) {
                    ProgressView()
                }
                .resizable()
                .frame(width: width, height: width)
            } else {
                // 默认头像
                DefaultAvatar(displayName:displayName, isLight: isLight)
            }
        }
        .frame(minWidth: width, minHeight: width)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .shadow(color: isLight ? .gray.opacity(0.4) : .clear ,radius: 5)
        .overlay {
            RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2), lineWidth: 1)
        }
    }
}

/// 默认头像
private struct DefaultAvatar: View {
    
    var displayName: String
    
    var isLight: Bool = false
    
    var body: some View {
        
        let avatarStr = displayName.first
        
        Text(avatarStr != nil ? String(avatarStr!) : "N")
            .font(.system(size: 48))
            .fontWeight(.semibold)
            .foregroundStyle(isLight ? .gray : .white)
    }
}

#Preview {
    UserAvatar(
        displayName: "Nola",
        avatar: nil
    )
}
