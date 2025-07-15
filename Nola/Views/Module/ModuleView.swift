//
//  ModuleView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI


/// 模块 View
struct ModuleView: View {
    
    @ObservedObject var contentVM: ContentViewModel
    
    @State var path = NavigationPath()
    
    @State private var showAlert = false
    @State private var alertMsg = ""
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                // 每行两列的网格布局
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(destButtons) { button in
                        NavigationLink(value: button.destination) {
                            // 按钮视觉样式
                            ModuleButton(button: button)
                        }
                    }
                }
                .padding()
                
            }
            .refreshable {
                if let err = await contentVM.refreshOverview() {
                    showAlert = true
                    alertMsg = err
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .post(let id):
                    PostView(path: $path, postIdFilter: id)
                case .tag:
                    TagView()
                case .category:
                    CategoryView()
                case .comment:
                    CommentView(path: $path)
                case .diary:
                    DiaryView(path: $path)
                default:
                    DetailView(title: "未完成")
                }
                
            }
            .navigationTitle("模块")
            .navigationBarTitleDisplayMode(.inline)
        }
        .messageAlert(isPresented: $showAlert, message: alertMsg)
        
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
