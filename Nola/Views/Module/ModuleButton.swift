//
//  ModuleButton.swift
//  Nola
//
//  Created by loac on 20/03/2025.
//

import SwiftUI

struct ModuleButton: View {
    
    var button: ModuleNav
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            HStack() {
                Image(systemName: button.icon)
                    .font(.title2)
                
                
                Spacer()
                
                Text(button.count < 0 ? "-" : String(button.count))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.label))
            }
            .padding(.horizontal)
            
            
            HStack {
                Spacer()
                Text(button.title)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .foregroundStyle(Color(.label))
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal, 5)
    }
}

#Preview {
    ModuleButton(button: ModuleNav(title: "文章", icon: "book", destination: Text("文章")))
}
