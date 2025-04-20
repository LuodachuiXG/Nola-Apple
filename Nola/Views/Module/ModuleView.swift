//
//  ModuleView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI

struct ModuleView: View {
    
    let buttons: [ModuleNavData] = [
        ModuleNavData(title: "文章", icon: "book", destination: DetailView(title: "文章"), count: 20),
        ModuleNavData(title: "标签", icon: "tag", destination: DetailView(title: "标签"), count: 5),
        ModuleNavData(title: "分类", icon: "books.vertical",  destination: DetailView(title: "分类"), count: 3),
        ModuleNavData(title: "评论", icon: "message", destination: DetailView(title: "评论"), count: 30),
        ModuleNavData(title: "日常", icon: "leaf", destination: DetailView(title: "日常"), count: 2),
        ModuleNavData(title: "附件", icon: "tray.full", destination: DetailView(title: "附件"), count: 312),
        ModuleNavData(title: "链接", icon: "at", destination: DetailView(title: "链接"), count: 8),
        ModuleNavData(title: "菜单", icon: "line.3.horizontal", destination: DetailView(title: "菜单"), count: 4)
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // 每行两列的网格布局
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(buttons) { button in
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
    ModuleView()
}
