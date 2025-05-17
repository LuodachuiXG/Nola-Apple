//
//  ModuleView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI

struct ModuleView: View {
    
    @ObservedObject var contentVM: ContentViewModel

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // 每行两列的网格布局
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(destButtons) { button in
                        NavigationLink {
                            button.destination
                        } label: {
                            // 按钮视觉样式
                            ModuleButton(button: button)
                        }
                    }
                }
                .padding()

            }
            .navigationTitle("模块")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}


struct DetailView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .navigationTitle(title)
    }
}

#Preview {
    ModuleView(contentVM: ContentViewModel())
}
