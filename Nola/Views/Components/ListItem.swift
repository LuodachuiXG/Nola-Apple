//
//  OptionItem.swift
//  Nola
//
//  Created by loac on 18/06/2025.
//


import Foundation
import SwiftUI
import SDWebImageSwiftUI

/// List 选项
struct ListItem<Content: View>: View {
    
    var label: String
    var content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            content
                .multilineTextAlignment(.trailing)
        }
    }
}
