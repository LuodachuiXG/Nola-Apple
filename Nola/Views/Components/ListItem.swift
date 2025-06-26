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
    var required: Bool
    
    init(label: String, required: Bool = false, @ViewBuilder content: () -> Content) {
        self.label = label
        self.required = required
        self.content = content()
    }
    
    var body: some View {
        HStack {
            if required {
                Text("*")
                    .foregroundStyle(.red)
            }
            Text(label)
            Spacer()
            content
                .multilineTextAlignment(.trailing)
        }
    }
}
