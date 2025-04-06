//
//  UserAvatar.swift
//  Nola
//
//  Created by loac on 25/03/2025.
//

import SwiftUI

struct UserAvatar: View {
    
    @Environment(\.colorScheme) var colorScheme
    private var isLight: Bool {
        colorScheme == .light
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Text("N")
                .font(.system(size: 48))
                .fontWeight(.semibold)
                .foregroundStyle(isLight ? .gray : .white)
        }
        .frame(minWidth: 80, minHeight: 80)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .shadow(color: isLight ? .gray.opacity(0.4) : .clear ,radius: 5)
        .overlay {
            RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.4), lineWidth: 2)
        }
    }
}

#Preview {
    UserAvatar()
}
