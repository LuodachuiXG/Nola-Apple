//
//  PostContentView.swift
//  Nola
//
//  Created by loac on 09/06/2025.
//

import Foundation
import SwiftUI

/// 文章内容编辑页面
struct PostContentView: View {
    
    @ObservedObject var vm: PostViewModel
    @Binding var post: Post
    
    @State private var isLoading = false
    
    // 文章内容
    @State private var content: PostContent? = nil
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    
    // 标记当前是否已经加载过，防止重复执行 task 导致文章刷新
    @State private var isLoaded = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {

            }
        }
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    NavigationLink {
                        
                    } label: {
                        Text("Hello")
                    }
                    
                    Button("选项二", action: { print("选项二") })
                    Divider()
                    Button("设置", action: { print("设置") })
                } label: {
                    Label("菜单", systemImage: "ellipsis.circle")
                }
            }
        }
        .task {
            if !isLoaded {
                isLoading = true
                let ret = await vm.getPostContent(id: post.postId)
                if let err = ret.error {
                    // 加载失败
                    alertMessage = err
                    showAlert = true
                } else if let postContent = ret.content {
                    // 获得文章内容
                    content = postContent
                }
                withAnimation {
                    isLoading = false
                }
                isLoaded = true
            }
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
