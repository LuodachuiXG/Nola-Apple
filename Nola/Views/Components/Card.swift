//
//  Card.swift
//  Nola
//
//  Created by loac on 25/03/2025.
//

import SwiftUI

struct Card<Content: View>: View {
    private var alignment: HorizontalAlignment
    private var spacing: CGFloat
    private var padding: CGFloat
    private let content: Content
    
    init(
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 15,
        padding: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
        .padding(padding)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ZStack {
        Card {
            Text("Preview Content").padding()
        }
    }
    .frame(maxWidth: .infinity,  maxHeight: .infinity)
}
