//
//  UserAvatar.swift
//  Nola
//
//  Created by loac on 25/03/2025.
//

import SwiftUI

struct UserAvatar: View {
    
    // 用户实体
    var user: User? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    private var isLight: Bool {
        colorScheme == .light
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if user != nil, let urlString = user?.avatar, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        // 错误显示头像
                        DefaultAvatar(user: user, isLight: isLight)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 80, height: 80)
            } else {
                // 默认头像
                DefaultAvatar(user: user, isLight: isLight)
            }
        }
        .frame(minWidth: 80, minHeight: 80)
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
    
    var user: User? = nil
    
    var isLight: Bool = false
    
    
    
    var body: some View {
        
        let avatarStr = user?.displayName.first
        
        Text(avatarStr != nil ? String(avatarStr!) : "N")
            .font(.system(size: 48))
            .fontWeight(.semibold)
            .foregroundStyle(isLight ? .gray : .white)
    }
}

#Preview {
    UserAvatar()
}
