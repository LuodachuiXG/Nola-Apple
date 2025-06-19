//
//  ModuleButton.swift
//  Nola
//
//  Created by loac on 20/03/2025.
//

import SwiftUI

/// 模块按钮
struct ModuleButton: View {
    
    var button: ModuleNavData
    
    var body: some View {
        
        Card(alignment: .leading, spacing: .defaultSpacing) {
            
            HStack() {
                Image(systemName: button.icon)
                    .font(.title2)
                
                
                Spacer()
                
                Text(button.count == nil || button.count! < 0 ? "-" : String(button.count!))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.label))
            }
            .padding(.horizontal)
            .padding(.top)
            
            
            HStack {
                Spacer()
                Text(button.title)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top, .defaultSpacing)
            .foregroundStyle(Color(.label))
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 5)
    }
}

#Preview {
    ModuleButton(button: ModuleNavData(title: "文章", icon: "book", destination: Text("文章"), count: 10))
}
